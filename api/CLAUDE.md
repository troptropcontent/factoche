# CLAUDE.md - Factoche API Project Documentation

## Project Overview

Factoche is a comprehensive **French construction invoicing and project management API** built with Rails 8. The application manages the complete lifecycle of construction projects from quotes to invoices, with full support for French legal requirements including Factur-X e-invoicing standards.

### Core Domains

1. **Organization Domain**: Business entities (companies, clients, projects, quotes, orders)
2. **Accounting Domain**: Financial transactions (invoices, proformas, credit notes, payments)

### Key Features

- Multi-tenant architecture with company-based access control
- Quote → Draft Order → Order → Invoice workflow
- Proforma invoices with conversion to final invoices
- French e-invoicing compliance (Factur-X/ZUGFeRD)
- PDF generation for all financial documents
- Real-time dashboard with WebSocket updates
- Payment tracking and invoice status management
- Retention guarantee calculations for construction projects

---

## Technology Stack

### Core Framework

- **Rails**: 8.0.0+ (API-only mode)
- **Ruby**: Version specified in `.ruby-version`
- **PostgreSQL**: Primary database with custom views
- **Redis**: Cable/WebSocket support

### Key Dependencies

- **Authentication**: JWT tokens (custom implementation)
- **Authorization**: Pundit policies
- **Validation**: dry-validation contracts
- **Serialization**: Custom OpenApiDto framework + Blueprinter (legacy)
- **Background Jobs**: Sidekiq 7.3
- **PDF Generation**: Ferrum (headless Chrome via CDP)
- **French E-invoicing**: Custom Factur-X implementation
- **Testing**: RSpec, FactoryBot, Shoulda Matchers, WebMock
- **API Documentation**: Rswag (OpenAPI/Swagger)
- **Error Tracking**: Sentry

---

## Architecture Overview

### Application Structure

```
app/
├── controllers/
│   ├── api/v1/                      # Versioned API endpoints
│   │   ├── auth/                    # Authentication (login, refresh)
│   │   └── organization/            # Business resources
│   └── concerns/
│       └── jwt_authenticatable.rb   # JWT authentication logic
├── models/
│   ├── organization/                # Business models (STI for projects)
│   └── accounting/                  # Financial transaction models
├── services/                        # Business logic layer
│   ├── organization/                # Business services
│   ├── accounting/                  # Financial services
│   ├── application_service.rb       # Service base with Result pattern
│   └── service_result.rb            # Result monad wrapper
├── contracts/                       # Input validation (dry-validation)
│   ├── organization/                # User input contracts
│   └── accounting/                  # Internal data schemas
├── policies/                        # Authorization rules (Pundit)
│   ├── organization/                # Business entity policies
│   └── accounting/                  # Financial transaction policies
├── dtos/                           # Response serialization
│   └── organization/                # OpenApiDto serializers
├── sidekiq/                        # Background jobs
│   ├── organization/                # Business jobs (PDF generation)
│   └── accounting/                  # Financial jobs (PDF, Factur-X)
└── lib/
    ├── open_api_dto.rb             # Custom DTO framework
    ├── error/                       # Custom error classes
    └── jwt_auth.rb                  # JWT utilities
```

---

## Core Architectural Patterns

### 1. Service Object Pattern

All business logic is encapsulated in service objects following the Result monad pattern.

**Base Service**: `ApplicationService` (app/services/application_service.rb)

```ruby
module ApplicationService
  extend ActiveSupport::Concern

  # Provides:
  # - .call(...) class method
  # - validate!(params, contract) for input validation
  # - Automatic ServiceResult wrapping
  # - Exception handling
end
```

**Service Result**: `ServiceResult` (app/services/service_result.rb)

```ruby
# Usage
result = SomeService.call(args)
if result.success?
  data = result.data
else
  error = result.error
end
```

**Service Organization**:

- Domain-based namespacing (`Organization::`, `Accounting::`)
- Action-oriented naming (`Create`, `Update`, `ConvertToOrder`)
- Builder services for complex attribute construction
- Orchestrator services for coordinating multiple operations

### 2. Organization vs Accounting Domain Separation

The codebase implements a clear separation of concerns between business logic and accounting logic, particularly visible in proforma/invoice services:

**Organization Module** (`Organization::Proformas`, `Organization::Invoices`):
- **Responsibility**: Business domain validation and orchestration
- **Concerns**:
  - Progressive invoicing business rules
  - Over-billing prevention (`ensure_invoiced_item_remains_within_limits!`)
  - Project version validation (must be last version)
  - Draft uniqueness constraints
  - Business entity loading and coordination
  - Building arguments for accounting layer
- **Example**: `Organization::Proformas::Create` validates that invoice amounts don't exceed order totals before delegating to accounting

**Accounting Module** (`Accounting::Proformas`, `Accounting::Invoices`):
- **Responsibility**: Pure accounting record-keeping and financial calculations
- **Concerns**:
  - Financial transaction record creation
  - Financial calculations (totals, tax, retention guarantee)
  - Financial year management and document numbering
  - Data integrity verification (`ensure_totals_are_correct!`)
  - Context snapshot preservation (immutable audit trail)
  - Accounting document lifecycle (draft → posted → voided)
  - Builder services for attributes, lines, and details
- **Example**: `Accounting::Proformas::Create` receives validated business data and creates accounting records with proper financial calculations

**Delegation Pattern**:
```ruby
# Organization layer validates business rules
Organization::Proformas::Create
  ↓ loads project/client/company
  ↓ validates business constraints
  ↓ builds accounting arguments (hash snapshot)
  ↓ delegates to ↓
Accounting::Proformas::Create
  ↓ creates financial transaction records
  ↓ calculates totals and taxes
  ↓ generates document number
  ↓ triggers PDF generation
```

**Key Design Benefits**:
- Clear separation between "what can be invoiced" (Organization) and "how to record it" (Accounting)
- Accounting module receives complete snapshots (hashes) rather than ActiveRecord objects, enforcing immutability
- Builder services in Accounting module are reusable and highly testable
- Context snapshots in financial transactions enable accurate historical reporting
- Complies with French accounting requirements for audit trails

**Example Flow** (`Organization::Proformas::Create:161-171`):
```ruby
def create_proforma!(issue_date)
  # Build accounting arguments as hash snapshot
  accounting_service_arguments = build_accounting_service_arguments(issue_date)

  # Delegate to accounting layer with complete snapshot
  result = Accounting::Proformas::Create.call(accounting_service_arguments)

  raise result.error if result.failure?
  result.data
end
```

### 3. Request Flow

```
HTTP Request
    ↓
Controller (Authentication via JWT)
    ↓
Authorization (Pundit policy_scope)
    ↓
Strong Parameters
    ↓
Service Object
    ↓
Validation (dry-validation contract)
    ↓
Business Logic (in transaction)
    ↓
Background Job (if needed)
    ↓
Response (OpenApiDto serialization)
```

### 4. Authentication & Authorization

**Authentication** (`app/controllers/concerns/jwt_authenticatable.rb`):

- JWT bearer tokens in `Authorization` header
- Access tokens with expiration
- Refresh token support via `/api/v1/auth/refresh`
- Custom JWT implementation in `lib/jwt_auth.rb`

**Authorization** (`app/policies/`):

- Pundit-based with default deny
- Policy scopes filter by company membership
- Multi-level scoping (Project → Client → Company → User)
- Applied via `policy_scope()` in controllers

**Example Policy Scope**:

```ruby
# app/policies/organization/project_policy.rb
class Scope < ApplicationPolicy::Scope
  def resolve
    scope
      .joins({ client: { company: :members } })
      .where({ client: { company: { organization_members: { user_id: user.id } } } })
  end
end
```

### 5. Validation Strategy

**Two-tier validation**:

1. **Strong Parameters** (Controllers): Basic Rails param filtering
2. **Dry-Validation Contracts** (Services): Business logic validation

**Contract Types**:

- `Dry::Validation::Contract`: User input validation (create/update operations)
- `Dry::Schema.Params`: Internal data structure validation (service-to-service)

**Example Contract**:

```ruby
# app/contracts/organization/quotes/create_contract.rb
class CreateContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:items).filled(:array).array(:hash) do
      required(:name).filled(:string)
      required(:quantity).filled(:integer)
      required(:unit_price_amount).filled(:decimal)
    end
  end

  # Custom cross-field validation
  rule(:items, :groups) do
    # Validation logic
  end
end
```

### 6. Serialization with OpenApiDto

Custom DTO framework providing type-safe, OpenAPI-compatible serialization.

**DTO Hierarchy**:

```
ShowDto/IndexDto (Wrapper)
    ↓
ExtendedDto/CompactDto (Resource representation)
    ↓
BaseExtendedDto/BaseCompactDto (Shared structure)
```

**Example**:

```ruby
class ShowDto < OpenApiDto
  field "result", :object, subtype: ExtendedDto
end

class ExtendedDto < BaseExtendedDto
  field "id", :integer
  field "status", :enum, subtype: ["draft", "posted"]
  field "items", :array, subtype: ItemDto
end
```

**Features**:

- Runtime type checking
- Required/optional field handling
- Nested object support
- Array validation with subtypes
- Enum validation
- Automatic OpenAPI schema generation

---

## Database Architecture

### Core Models

**Organization Domain** (`organization_*` tables):

- `companies`: Legal entities with multi-tenant isolation
- `clients`: Customer records per company
- `projects`: STI base for Quote/DraftOrder/Order
- `project_versions`: Versioned snapshots of projects
- `items`: Line items within project versions
- `item_groups`: Grouping mechanism for items
- `bank_details`: Company bank accounts
- `members`: User-company associations

**Accounting Domain** (`accounting_*` tables):

- `financial_transactions`: Polymorphic base for Invoice/Proforma/CreditNote
- `financial_transaction_lines`: Line items for financial documents
- `financial_transaction_details`: Snapshot of parties/terms at transaction time
- `financial_years`: Accounting periods for document numbering
- `payments`: Payment records against invoices

### Single Table Inheritance (STI)

**Projects**: `organization_projects.type`

- `Organization::Quote`
- `Organization::DraftOrder`
- `Organization::Order`

**Financial Transactions**: `accounting_financial_transactions.type`

- `Accounting::Invoice`
- `Accounting::Proforma`
- `Accounting::CreditNote`

### Database Views (Scenic)

1. **monthly_revenues**: Aggregated revenue by company/year/month
2. **order_completion_percentages**: Order progress tracking (invoiced vs total)
3. **invoice_payment_statuses**: Payment status (paid/pending/overdue)

### Key Relationships

```
User ←→ Member ←→ Company
                     ↓
                   Client
                     ↓
                  Project (Quote/DraftOrder/Order)
                     ↓
              ProjectVersion
                     ↓
                ItemGroup ← Item

Company → FinancialTransaction (Invoice/Proforma/CreditNote)
               ↓
    FinancialTransactionLine
    FinancialTransactionDetail
               ↓
           Payment (invoices only)
```

---

## Key Business Workflows

### 1. Quote to Order Lifecycle

```
Quote (created)
    ↓ convert_to_draft_order
DraftOrder
    ↓ convert_to_order
Order (posted = true)
    ↓ create proforma/invoice
Invoice/Proforma
    ↓ record payment
Payment
```

**Implementation**:

- `Organization::Quotes::ConvertToDraftOrder` service
- `Organization::DraftOrders::ConvertToOrder` service
- Each conversion creates a new project with duplicated version

### 2. Project Versioning

Projects maintain version history via `project_versions`:

- Each edit creates a new version with incremented number
- Items tracked across versions via `original_item_uuid`
- Version numbers: `v1`, `v2`, `v3`, etc.
- Last version used for current state

### 3. Invoice Generation

The application currently supports **progressive invoicing** (also known as partial billing) for construction projects, allowing contractors to bill clients incrementally as work is completed.

**Progressive Invoicing Workflow**:

1. **Completion Percentage Tracking**

   - Users record completion percentages for each order item
   - Each item tracks: current completion % and amount previously billed
   - Items can be billed multiple times as work progresses

2. **Incremental Billing Calculation**

   ```
   Billable Amount = (Item Total × New Completion %) - Previously Billed Amount

   Example:
   - Item total: €10,000
   - Previously billed: 40% (€4,000)
   - New completion: 70%
   - Current invoice: €10,000 × 70% - €4,000 = €3,000
   ```

3. **Invoice Creation Process**

   - User creates invoice/proforma for an order
   - Specifies the amount to billed for each item (the front end is responsible of displaying previous billed and send the billable amount)
   - Invoice line items store the billed amountq for each items

4. **Tracking & Validation**
   - System prevents over-billing (total billed cannot exceed item total)
   - Dashboard shows completion percentages per order (via `order_completion_percentages` view)
   - Each invoice stores snapshot of project/version metadata in context

**Proforma to Invoice Conversion**:

- Proformas can be drafted and posted (converted to invoice)
- `Accounting::Proformas::Post` service handles conversion
- Useful for requiring client approval before finalizing invoices

### 4. Payment Tracking

- Payments recorded against invoices
- `invoice_payment_statuses` view calculates:
  - `paid`: Balance = 0
  - `overdue`: Balance > 0 and past due_date
  - `pending`: Balance > 0 and not overdue

### 5. Credit Notes

- Created when invoices are cancelled
- `Accounting::Invoices::Cancel` creates credit note
- Links to original invoice via `holder_id`
- Subtracts from revenue calculations

---

## PDF Generation Infrastructure

### Architecture

```
Service (creates record)
    ↓
Sidekiq Job (async)
    ↓
HeadlessBrowserPdfGenerator
    ↓
Remote Chrome (via WebSocket)
    ↓
Active Storage (S3/local)
```

### Components

**Jobs**:

- `GenerateAndAttachPdfToRecordJob`: Generic PDF generation
- `Organization::ProjectVersions::GeneratePdfJob`: Quote/Order PDFs
- `Accounting::FinancialTransactions::GenerateAndAttachPdfJob`: Invoice/Proforma PDFs
- `Accounting::FinancialTransactions::GenerateAndAttachFacturXJob`: Factur-X compliance

**Generator** (`app/services/headless_browser_pdf_generator.rb`):

- Connects to headless Chrome via WebSocket
- Configured via `config/headless_browser.yml`
- Uses Ferrum (Chrome DevTools Protocol)
- Generates PDF from HTML print routes

**Print Routes**:

- `/prints/quotes/:quote_id/quote_versions/:id` - Quote PDFs
- `/prints/draft_orders/:draft_order_id/draft_order_versions/:id` - Draft order PDFs
- `/prints/orders/:order_id/order_versions/:id` - Order PDFs
- `/accounting/prints/published_invoices/:id` - Invoice PDFs
- `/accounting/prints/credit_notes/:id` - Credit note PDFs

### Factur-X Generation

French e-invoicing standard (ZUGFeRD profile):

- Combines PDF with embedded XML metadata
- Uses external microservice at `http://factur_x:5000`
- XML generation: `Accounting::FacturX::GenerateXml` service
- PDF hybrid: `Accounting::FacturX::GeneratePdf` service
- Complies with French legal requirements

---

## API Design

### Endpoint Structure

```
/api/v1/
  /auth
    POST /login          # JWT token generation
    POST /refresh        # Token refresh
  /organization
    /companies/:company_id
      GET    /            # Company details
      PATCH  /            # Update company
      GET    /dashboard   # Company dashboard (KPIs, charts)
      /clients
        GET    /          # List clients
        POST   /          # Create client
        /quotes
          POST /          # Create quote for client
      /projects
        GET    /          # List projects
        POST   /          # Create project
      /quotes
        GET    /          # List quotes
      /draft_orders
        GET    /          # List draft orders
      /orders
        GET    /          # List orders
      /invoices
        GET    /          # List invoices
      /proformas
        GET    /          # List proformas
      /credit_notes
        GET    /          # List credit notes
    /quotes/:id
      GET    /                    # Show quote
      PATCH  /                    # Update quote
      POST   /convert_to_draft_order  # Convert to draft order
    /draft_orders/:id
      GET    /                    # Show draft order
      PATCH  /                    # Update draft order
      POST   /convert_to_order    # Convert to order
    /orders/:id
      GET    /                    # Show order
      PATCH  /                    # Update order
      /proformas
        POST /                    # Create proforma for order
    /proformas/:id
      GET    /                    # Show proforma
      PATCH  /                    # Update proforma
      POST   /                    # Post (convert to invoice)
      DELETE /                    # Void proforma
    /invoices/:id
      GET    /                    # Show invoice
      POST   /cancel              # Cancel (creates credit note)
    /payments
      POST   /                    # Record payment
```

### Response Format

**Success** (show endpoint):

```json
{
  "result": {
    "id": 1,
    "status": "posted",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

**Success** (index endpoint):

```json
{
  "results": [
    { "id": 1, "status": "posted" },
    { "id": 2, "status": "draft" }
  ],
  "meta": {
    "total": 2
  }
}
```

**Error**:

```json
{
  "error": {
    "status": "unprocessable_entity",
    "code": 422,
    "message": "Validation failed",
    "details": {
      "name": [{ "type": "blank", "message": "can't be blank" }]
    }
  }
}
```

---

## Error Handling

### Error Classes (`app/lib/error/`)

- `ApplicationError` (base)
- `BadRequestError` (400)
- `UnauthorizedError` (401)
- `ForbiddenError` (403)
- `NotFoundError` (404)
- `ConflictError` (409)
- `UnprocessableEntityError` (422)
- `InternalServerError` (500)
- `ServiceUnavailableError` (503)

### Error Handler (`app/lib/error/handler.rb`)

Centralized exception handling with Sentry integration:

- Catches all exceptions in API controllers
- Maps exceptions to HTTP status codes
- Formats error responses consistently
- Sends errors to Sentry for tracking
- Handles ActiveRecord validation errors

---

## Testing Strategy

### Test Suite

**Framework**: RSpec with Rails integration

**Structure**:

```
spec/
├── models/                  # Model specs (associations, validations)
├── controllers/             # Request specs for API endpoints
├── services/                # Service object specs
├── sidekiq/                 # Background job specs
├── lib/                     # Library specs (OpenApiDto, JwtAuth)
├── factories/               # FactoryBot factories
└── support/
    └── helpers/
        └── authentication.rb  # Auth helpers for tests
```

**Key Tools**:

- **FactoryBot**: Test data generation
- **Shoulda Matchers**: Model validation/association matchers
- **WebMock**: HTTP request stubbing
- **DatabaseCleaner**: Test database cleanup
- **Sidekiq::Testing**: Job testing utilities

**Test Configuration** (`spec/rails_helper.rb`):

- Transactional fixtures enabled
- Sidekiq fake mode (jobs don't execute)
- Database cleaner with transaction strategy
- Authentication helpers included for request specs

### Test Coverage

The codebase has comprehensive test coverage including:

- Model validations and associations
- Controller authorization and responses
- Service object business logic
- Background job execution
- DTO serialization
- Custom library functionality

---

## Configuration & Environment

### Key Configuration Files

**Application**:

- `config/application.rb`: Rails configuration, API-only mode, middleware
- `config/routes.rb`: API versioning, nested resources, custom actions
- `config/database.yml`: PostgreSQL configuration
- `config/cable.yml`: ActionCable (WebSocket) configuration
- `config/storage.yml`: Active Storage (S3 for production, local for dev)

**Custom Configs**:

- `config/headless_browser.yml`: Headless Chrome WebSocket connection
- `config/facturx_defaults.yml`: French e-invoicing defaults

**Deployment**:

- `config/deploy.yml`: Kamal deployment base
- `config/deploy.staging.yml`: Staging environment
- `config/deploy.production.yml`: Production environment

### Environment Variables

**Required**:

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection for ActionCable
- `SECRET_KEY_BASE`: Rails secret for sessions/encryption
- `HEADLESS_BROWSER_WS`: WebSocket URL for headless Chrome
- `HEADLESS_BROWSER_TOKEN`: Auth token for Chrome connection
- `SENTRY_DSN`: Sentry error tracking URL
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`: S3 credentials (production)
- `AWS_REGION`, `AWS_BUCKET`: S3 configuration (production)

**Optional**:

- `RAILS_MAX_THREADS`: Puma thread pool size (default: 5)
- `PAGE_LOAD_TIMEOUT`: PDF generation timeout (default: 2000ms)

---

## Development Workflow

### Important: Environment Variables

**All Rails commands require loading environment variables from the dotenv file:**

```bash
# Load development environment variables
bundle exec dotenv -f config/.env.development rails <command>

# Example: Running migrations
bundle exec dotenv -f config/.env.development rails db:migrate

# Example: Starting the server
bundle exec dotenv -f config/.env.development rails server
```

For convenience, you can use the `Makefile` which handles environment loading automatically.

### Setup

```bash
# Install dependencies
bundle install

# Setup database (with environment variables loaded)
bundle exec dotenv -f config/.env.development rails db:create db:migrate db:seed

# Run tests (RSpec automatically loads test environment)
bundle exec rspec

# Start server (with environment variables loaded)
bundle exec dotenv -f config/.env.development rails server

# Start Sidekiq (separate terminal)
bundle exec sidekiq

# Access Sidekiq Web UI
open http://localhost:3000/sidekiq
```

### Database Operations

```bash
# Note: All these commands require dotenv wrapper for environment variables

# Create migration
bundle exec dotenv -f config/.env.development rails generate migration MigrationName

# Run migrations
bundle exec dotenv -f config/.env.development rails db:migrate

# Rollback
bundle exec dotenv -f config/.env.development rails db:rollback

# Reset database (DESTRUCTIVE)
bundle exec dotenv -f config/.env.development rails db:drop db:create db:migrate db:seed

# Update views (Scenic)
bundle exec dotenv -f config/.env.development rails db:migrate:up VERSION=<version_number>
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run specific file
bundle exec rspec spec/services/organization/quotes/create_spec.rb

# Run with tag
bundle exec rspec --tag focus

# Run with coverage
COVERAGE=true bundle exec rspec
```

### API Documentation

```bash
# Generate Swagger/OpenAPI docs
bin/rails rswag:specs:swaggerize

# Access API docs
open http://localhost:3000/api-docs
```

---

## Code Organization Best Practices

### Controllers

- Keep controllers thin - delegate to services
- Use `policy_scope` for all resource queries
- Use `load_and_authorise_resource` for show/update/destroy
- Strong parameters for input filtering
- DTOs for response serialization

### Services

- One service per business action
- Include `ApplicationService` for modern services
- Use contracts for validation
- Wrap operations in `ActiveRecord::Base.transaction`
- Return domain objects, not DTOs
- Trigger background jobs after transaction commits

### Models

- Keep business logic minimal
- Validations for data integrity only
- Associations and scopes
- Enum definitions
- Calculated attributes (avoid complex logic)

### Policies

- Default deny (return false in ApplicationPolicy)
- Scope by company membership
- Reuse base queries with class methods
- One policy per model

### Contracts

- One contract per action (Create, Update)
- Use `required()` for mandatory fields
- Use `optional()` for optional fields
- Custom rules for cross-field validation
- Schemas for internal data structures

### DTOs

- Three-tier hierarchy (Wrapper → Data → Base)
- CompactDto for index, ExtendedDto for show
- Field types match OpenAPI spec
- Nested DTOs for complex structures

---

## Deployment

### Kamal (Docker-based)

The application is deployed using Kamal:

- Dockerized Rails application
- PostgreSQL database
- Redis for ActionCable
- Headless Chrome service
- Factur-X microservice

**Environments**:

- `staging`: `config/deploy.staging.yml`
- `production`: `config/deploy.production.yml`

### Key Deployment Commands

```bash
# Setup (first time)
kamal setup

# Deploy
kamal deploy

# Check status
kamal app logs

# Console
kamal app exec -i --reuse bash
```

---

## Known Considerations & Technical Debt

### Recent Refactoring

Based on git status, the following was recently removed:

- `Organization::CompletionSnapshot` model and related tables
- `app/contracts/organization/invoices/completion_snapshots/create_contract.rb`
- Related migration: `20251202085700_drop_organization_completion_snapshots_and_organization_completion_snapshot_items.rb`

**Impact**: Some jobs/services may reference deleted models:

- `Organization::GenerateAndAttachPdfToInvoiceJob` (app/sidekiq/organization/generate_and_attach_pdf_to_invoice_job.rb)

### Service Pattern Coexistence

Two service patterns exist in the codebase:

1. **Modern**: `include ApplicationService` with instance `#call` method
2. **Legacy**: Class-level `.call` with manual ServiceResult creation

**Recommendation**: Gradually migrate legacy services to modern pattern.

### Areas for Future Enhancement

1. **API Versioning**: Currently only v1 exists, consider versioning strategy
2. **Rate Limiting**: No rate limiting implemented
3. **Pagination**: Some index endpoints may need pagination for large datasets
4. **Caching**: Limited caching strategy (consider Redis caching)
5. **Audit Trail**: No change tracking for financial documents
6. **Soft Deletes**: Hard deletes may cause referential integrity issues

---

## Key File Reference

### Critical Files to Understand

1. **Application Core**:

   - `app/controllers/api/v1/api_v1_controller.rb` - Base controller
   - `app/services/application_service.rb` - Service pattern base
   - `app/lib/open_api_dto.rb` - DTO framework
   - `app/lib/error/handler.rb` - Error handling
   - `app/controllers/concerns/jwt_authenticatable.rb` - Authentication

2. **Business Logic Examples**:

   - `app/services/organization/quotes/create.rb` - Quote creation
   - `app/services/organization/draft_orders/convert_to_order.rb` - State transition
   - `app/services/accounting/proformas/post.rb` - Proforma posting
   - `app/services/accounting/invoices/cancel.rb` - Invoice cancellation

3. **Models**:

   - `app/models/organization/project.rb` - STI base
   - `app/models/accounting/financial_transaction.rb` - Financial STI base
   - `app/models/organization/company.rb` - Multi-tenant root

4. **Database**:

   - `db/schema.rb` - Current schema
   - `db/structure.sql` - Views (if using scenic)
   - `db/seeds.rb` - Seed data

5. **Configuration**:
   - `config/routes.rb` - API routes
   - `config/initializers/` - Rails initializers
   - `Gemfile` - Dependencies

---

## Support & Resources

### Documentation

- **API Docs**: http://localhost:3000/api-docs (Swagger UI)
- **Sidekiq UI**: http://localhost:3000/sidekiq
- **Health Check**: http://localhost:3000/up

### External Services

- **Headless Browser**: Ferrum connecting to remote Chrome via WebSocket
- **Factur-X Service**: Microservice at `http://factur_x:5000`
- **Sentry**: Error tracking and monitoring
- **AWS S3**: File storage (production)

### Useful Commands

```bash
# Rails console (with environment variables)
bundle exec dotenv -f config/.env.development rails console

# Database console (with environment variables)
bundle exec dotenv -f config/.env.development rails dbconsole

# Routes (with environment variables)
bundle exec dotenv -f config/.env.development rails routes

# Pending migrations (with environment variables)
bundle exec dotenv -f config/.env.development rails db:migrate:status

# Clear Sidekiq queue
# In Rails console:
Sidekiq::Queue.new.clear

# Check job status
# In Rails console:
Sidekiq::Stats.new
```

---

## Contributing Guidelines

### Code Style

- Follow Rubocop Rails Omakase rules
- Run `rubocop -a` before committing
- Security checks with `brakeman`

### Commit Messages

- Use conventional commit format
- Reference issue numbers where applicable

### Pull Request Process

1. Create feature branch from `main`
2. Write tests for new functionality
3. Ensure all tests pass (`bundle exec rspec`)
4. Run Rubocop and Brakeman
5. Update documentation if needed
6. Submit PR with description

---

## Appendix: Domain Model Summary

### Organization Domain

| Model          | Purpose                               | Key Relationships                        |
| -------------- | ------------------------------------- | ---------------------------------------- |
| Company        | Legal entity, multi-tenant root       | has_many :clients, :projects, :members   |
| Client         | Customer of a company                 | belongs_to :company, has_many :projects  |
| Project        | Base for Quote/DraftOrder/Order (STI) | belongs_to :client, has_many :versions   |
| ProjectVersion | Versioned project snapshot            | belongs_to :project, has_many :items     |
| Item           | Line item in a version                | belongs_to :project_version, :item_group |
| ItemGroup      | Grouping of items                     | has_many :items                          |
| Member         | User-company association              | belongs_to :user, :company               |
| BankDetail     | Company bank accounts                 | belongs_to :company                      |
| CompanyConfig  | Company settings                      | belongs_to :company                      |

### Accounting Domain

| Model                      | Purpose                                    | Key Relationships                     |
| -------------------------- | ------------------------------------------ | ------------------------------------- |
| FinancialTransaction       | Base for Invoice/Proforma/CreditNote (STI) | belongs_to :company, :client, :holder |
| FinancialTransactionLine   | Line item in financial doc                 | belongs_to :financial_transaction     |
| FinancialTransactionDetail | Snapshot of parties/terms                  | belongs_to :financial_transaction     |
| Payment                    | Payment against invoice                    | belongs_to :invoice                   |
| FinancialYear              | Accounting period                          | belongs_to :company                   |
| InvoicePaymentStatus       | View: payment status                       | belongs_to :invoice                   |

### Enums

**LegalForm**: `sasu`, `sas`, `eurl`, `sa`, `auto_entrepreneur`
**FinancialTransactionStatus**: `draft`, `voided`, `posted`, `cancelled`
**InvoiceStatus**: `draft`, `published`, `cancelled`
**PaymentStatus**: `paid`, `pending`, `overdue`

---

**Last Updated**: 2025-12-02
**Rails Version**: 8.0.0+
**Ruby Version**: See `.ruby-version`
- you should use RAILS_ENV=test bundle exec dotenv -f config/.env.development, update the claude.md file maybe to remember this
- For services, try to code with TDD as much as possible