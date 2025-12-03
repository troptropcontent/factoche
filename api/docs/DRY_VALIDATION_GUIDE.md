# dry-validation Guide

This project uses **dry-validation** instead of Rails Strong Parameters for data validation.

## Overview

dry-validation is a data validation library that provides a powerful DSL for defining schemas and validation rules through contract objects. It separates strict, explicit data schemas from domain validation logic, allowing type-safe rules that focus exclusively on validation.

**Key Features:**

- Separation of schema (type checking) from business rules
- Powered by dry-schema for data sanitization, coercion, and type-checking
- Support for custom macros to reduce code duplication
- Dependency injection support
- Type-safe validation rules

## Basic Contract Structure

```ruby
class NewUserContract < Dry::Validation::Contract
  # Schema definition (type checking & structure)
  params do
    required(:email).filled(:string)
    required(:age).value(:integer)
  end

  # Business rules (domain validation)
  rule(:email) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('has invalid format')
    end
  end

  rule(:age) do
    key.failure('must be greater than 18') if value <= 18
  end
end

# Usage
contract = NewUserContract.new
result = contract.call(email: 'jane@doe.org', age: 17)
result.success? # => false
result.errors.to_h # => {:age=>["must be greater than 18"]}
```

## Schema Definition (params block)

The `params` block defines the data structure and performs type checking before business rules are applied.

### Common Schema Macros

```ruby
params do
  # Required fields
  required(:name).filled(:string)           # Must be present and non-empty
  required(:age).value(:integer)            # Must be present, can be nil

  # Optional fields
  optional(:bio).filled(:string)            # Can be missing, but if present must be filled
  optional(:nickname).maybe(:string)        # Can be missing or nil

  # Nested hashes
  required(:address).hash do
    required(:street).filled(:string)
    required(:city).filled(:string)
    required(:zipcode).filled(:string)
  end

  # Arrays
  required(:tags).array(:string)            # Array of strings

  # Arrays of hashes
  required(:contacts).array(:hash) do
    required(:name).filled(:string)
    required(:phone).filled(:string)
  end
end
```

### Common Type Predicates

- `:string` - String type
- `:integer` - Integer type
- `:float` - Float type
- `:decimal` - Decimal type
- `:bool` - Boolean type
- `:date` - Date type
- `:date_time` - DateTime type
- `:time` - Time type
- `:hash` - Hash type
- `:array` - Array type

### Common Predicates

- `filled?` - Not nil and not empty (for strings/arrays/hashes)
- `empty?` - Empty string, array, or hash
- `gt?(n)` - Greater than n
- `gteq?(n)` - Greater than or equal to n
- `lt?(n)` - Less than n
- `lteq?(n)` - Less than or equal to n
- `min_size?(n)` - Minimum size for arrays/strings
- `max_size?(n)` - Maximum size for arrays/strings
- `included_in?(list)` - Value is in the given list
- `excluded_from?(list)` - Value is not in the given list
- `eql?(value)` - Equal to specific value
- `format?(regex)` - Matches regex pattern

### Predicate Logic Operators

```ruby
params do
  # AND operator
  required(:age) { int? & gt?(18) }

  # OR operator
  required(:age) { none? | int? }

  # Implication (then)
  required(:age) { filled? > int? }

  # XOR (exclusive or)
  required(:status) { even? ^ lt?(0) }
end
```

## Business Rules (rule blocks)

Rules are applied AFTER the schema successfully processes the input. They contain domain-specific validation logic.

### Simple Rules

```ruby
rule(:start_date) do
  key.failure('must be in the future') if value <= Date.today
end
```

### Rules with Multiple Dependencies

```ruby
rule(:end_date, :start_date) do
  if values[:end_date] < values[:start_date]
    key.failure('must be after start date')
  end
end
```

### Nested Key Rules

```ruby
# Using hash notation
rule(address: :city) do
  key.failure('must be a valid city') unless valid_city?(value)
end

# Using dot notation
rule('address.city') do
  key.failure('must be a valid city') unless valid_city?(value)
end
```

### Accessing Values in Rules

```ruby
rule(:start_date) do
  value  # Returns values[:start_date]
end

rule(date: :start) do
  value  # Returns values[:date][:start]
end

rule(dates: [:start, :stop]) do
  value  # Returns [values[:dates][:start], values[:dates][:stop]]
end

# Check if key exists
rule(:password) do
  if key?(:login) && values[:login]
    key.failure('password is required') unless value
  end
end
```

### Setting Failures

```ruby
# Key-specific failure (most common)
rule(:email) do
  key.failure('invalid format') unless valid_email?(value)
end

# Failure on different key
rule(:start_date) do
  key(:event_errors).failure('date issue')
end

# Base failure (not associated with specific key)
rule(:start_date, :end_date) do
  base.failure('invalid date range') if values[:end_date] < values[:start_date]
end
```

## Macros

Macros reduce code duplication for common validation patterns.

### Global Macros

```ruby
# Define once, use everywhere
Dry::Validation.register_macro(:email_format) do
  unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    key.failure('not a valid email format')
  end
end

# Use in any contract
class UserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
  end

  rule(:email).validate(:email_format)
end
```

### Contract-Level Macros

```ruby
class ApplicationContract < Dry::Validation::Contract
  register_macro(:email_format) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure('not a valid email format')
    end
  end
end

# Available to this class and descendants
class UserContract < ApplicationContract
  params do
    required(:email).filled(:string)
  end

  rule(:email).validate(:email_format)
end
```

### Parameterized Macros

```ruby
class ApplicationContract < Dry::Validation::Contract
  register_macro(:min_size) do |macro:|
    min = macro.args[0]
    unless value.size >= min
      key.failure("must have at least #{min} elements")
    end
  end
end

class ArrayContract < ApplicationContract
  params do
    required(:items).array(:string)
  end

  rule(:items).validate(min_size: 3)
end
```

## External Dependencies

Inject external services (like database repositories) into contracts.

```ruby
class NewUserContract < Dry::Validation::Contract
  option :user_repo
  option :address_validator

  params do
    required(:email).filled(:string)
    required(:address).filled(:string)
  end

  rule(:email) do
    key.failure('already taken') if user_repo.exists?(email: value)
  end

  rule(:address) do
    key.failure('invalid address') unless address_validator.valid?(value)
  end
end

# Usage
contract = NewUserContract.new(
  user_repo: UserRepository.new,
  address_validator: AddressValidator.new
)

result = contract.call(email: 'test@example.com', address: '123 Main St')
```

### Optional Dependencies

```ruby
class UpdateUserContract < Dry::Validation::Contract
  option :user_repo, optional: true

  params do
    required(:user_id).filled(:string)
  end

  rule(:user_id) do
    if user_repo
      key.failure('not found') unless user_repo.find(value)
    end
  end
end
```

## Context

Context allows passing data between rules and accessing it in validation.

```ruby
class UpdateUserContract < Dry::Validation::Contract
  option :user_repo

  params do
    required(:user_id).filled(:string)
  end

  rule(:user_id) do |context:|
    # Store data in context
    context[:user] ||= user_repo.find(value)
    key.failure('not found') unless context[:user]
  end

  rule(:email) do |context:|
    # Access data from context
    user = context[:user]
    key.failure('email unchanged') if user && user.email == value
  end
end

# Pass initial context
contract = UpdateUserContract.new(user_repo: UserRepo.new)
result = contract.call({user_id: 42}, user: existing_user)

# Access context from result
result.context[:user]

# Set default context
contract = UpdateUserContract.new(
  user_repo: UserRepo.new,
  default_context: {user: user}
)
```

## Working with Results

```ruby
result = contract.call(params)

# Check success
result.success? # => true/false
result.failure? # => true/false

# Access validated data
result.to_h
result[:email]

# Access errors
result.errors.to_h  # => {:email => ["is invalid"]}
result.errors.messages  # Human-readable messages
result.errors(full: true)  # Full error messages with field names
result.errors(locale: :fr)  # Errors in different locale

# Check specific errors
result.errors[:email]
```

## Message Customization

### Using I18n

```ruby
class ApplicationContract < Dry::Validation::Contract
  config.messages.backend = :i18n

  register_macro(:email_format) do
    unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
      key.failure(:email_format)  # Use symbol for i18n lookup
    end
  end
end
```

In your locale file (`config/locales/en.yml`):

```yaml
en:
  dry_validation:
    errors:
      email_format: "is not a valid email format"
      rules:
        email:
          email_format: "must be a valid email address"
```

## Rails Integration

### In Controllers

```ruby
class UsersController < ApplicationController
  def create
    result = UserContract.new.call(user_params)

    if result.success?
      @user = User.create!(result.to_h)
      redirect_to @user
    else
      @errors = result.errors.to_h
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :age)
  end
end
```

### In Models (for additional validation)

```ruby
class User < ApplicationRecord
  def self.contract
    @contract ||= UserContract.new
  end

  def validate_with_contract(params)
    result = self.class.contract.call(params)

    unless result.success?
      result.errors.to_h.each do |key, messages|
        messages.each { |msg| errors.add(key, msg) }
      end
    end

    result.success?
  end
end
```

## Common Patterns

### Email Validation

```ruby
Dry::Validation.register_macro(:email) do
  unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    key.failure('must be a valid email')
  end
end
```

### Uniqueness Check

```ruby
class UserContract < Dry::Validation::Contract
  option :user_repo

  params do
    required(:email).filled(:string)
  end

  rule(:email) do
    key.failure('already exists') if user_repo.exists?(email: value)
  end
end
```

### Conditional Validation

```ruby
class RegistrationContract < Dry::Validation::Contract
  params do
    required(:type).filled(:string)
    optional(:company_name).maybe(:string)
    optional(:personal_name).maybe(:string)
  end

  rule(:company_name) do
    if values[:type] == 'business' && !value
      key.failure('is required for business accounts')
    end
  end

  rule(:personal_name) do
    if values[:type] == 'personal' && !value
      key.failure('is required for personal accounts')
    end
  end
end
```

### Password Confirmation

```ruby
class PasswordContract < Dry::Validation::Contract
  params do
    required(:password).filled(:string)
    required(:password_confirmation).filled(:string)
  end

  rule(:password_confirmation) do
    unless values[:password] == values[:password_confirmation]
      key.failure('must match password')
    end
  end
end
```

### Date Range Validation

```ruby
class EventContract < Dry::Validation::Contract
  params do
    required(:start_date).value(:date)
    required(:end_date).value(:date)
  end

  rule(:start_date) do
    key.failure('must be in the future') if value <= Date.today
  end

  rule(:end_date, :start_date) do
    if values[:end_date] < values[:start_date]
      key.failure('must be after start date')
    end
  end
end
```

## Best Practices

1. **Separate Schema from Business Logic**: Keep type checking in `params` block, business rules in `rule` blocks

2. **Use Macros for Reusable Validation**: Create macros for validation logic used across multiple contracts

3. **Leverage External Dependencies**: Inject repositories and services rather than accessing them directly

4. **Keep Rules Simple**: Each rule should focus on one concern

5. **Use Context for Shared Data**: When multiple rules need the same computed value, store it in context

6. **Name Contracts Clearly**: Use descriptive names like `CreateUserContract`, `UpdateOrderContract`

7. **Test Contracts Independently**: Write unit tests for your contracts

8. **Use I18n for Messages**: Externalize error messages for internationalization

## Comparison with Strong Parameters

| Feature              | Strong Parameters | dry-validation                        |
| -------------------- | ----------------- | ------------------------------------- |
| Type coercion        | Basic             | Advanced with dry-schema              |
| Nested validation    | Limited           | Full support                          |
| Business rules       | No                | Yes                                   |
| Reusability          | Low               | High (macros, inheritance)            |
| Dependency injection | No                | Yes                                   |
| Complexity           | Simple            | More powerful, steeper learning curve |
| Performance          | Fast              | Faster (benchmarked)                  |

## Resources

- Official Documentation: https://dry-rb.org/gems/dry-validation/
- dry-schema Documentation: https://dry-rb.org/gems/dry-schema/
- GitHub Repository: https://github.com/dry-rb/dry-validation
