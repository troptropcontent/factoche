/**
 * This file was auto-generated by openapi-typescript.
 * Do not make direct changes to the file.
 */

export interface paths {
    "/api/v1/auth/login": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Creates a session */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: {
                content: {
                    "application/json": {
                        session?: {
                            /** @example user@example.com */
                            email: string;
                            /** @example password123 */
                            password: string;
                        };
                    };
                };
            };
            responses: {
                /** @description session created */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            access_token: string;
                            refresh_token: string;
                        };
                    };
                };
                /** @description invalid credentials */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            error: {
                                status: string;
                                code: number;
                                message: string;
                                details: Record<string, never>;
                            };
                        };
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/auth/refresh": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Refresh the access token */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description access token refreshed */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            access_token: string;
                        };
                    };
                };
                /** @description expired token */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            error: {
                                status: string;
                                code: number;
                                message: string;
                                details: Record<string, never>;
                            };
                        };
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/clients": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Lists clients for a company */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description clients found */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["client"][];
                    };
                };
                /** @description unauthorized */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
                /** @description company not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
            };
        };
        put?: never;
        /** Creates a client for a company */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                };
                cookie?: never;
            };
            requestBody: {
                content: {
                    "application/json": {
                        name: string;
                        registration_number: string;
                        email: string;
                        phone: string;
                        address_street: string;
                        address_city: string;
                        address_zipcode: string;
                    };
                };
            };
            responses: {
                /** @description client created */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["client"];
                    };
                };
                /** @description unauthorized */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
                /** @description company not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
                /** @description client is invalid */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Lists user companies */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path?: never;
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description successfully lists user's companies */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            id: number;
                            name: string;
                            registration_number: string;
                            email: string;
                            phone: string;
                            address_city: string;
                            address_street: string;
                            address_zipcode: string;
                        }[];
                    };
                };
                /** @description unauthorized */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            error: {
                                status: string;
                                code: number;
                                message: string;
                                details: Record<string, never>;
                            };
                        };
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Shows a specific company */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description successfully shows the company */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            id: number;
                            name: string;
                            registration_number: string;
                            email: string;
                            phone: string;
                            address_city: string;
                            address_street: string;
                            address_zipcode: string;
                        };
                    };
                };
                /** @description unauthorized */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            error: {
                                status: string;
                                code: number;
                                message: string;
                                details: Record<string, never>;
                            };
                        };
                    };
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            error: {
                                status: string;
                                code: number;
                                message: string;
                                details: Record<string, never>;
                            };
                        };
                    };
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/completion_snapshots": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Create a new completion snapshot on the project's last version */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                    project_id: number;
                };
                cookie?: never;
            };
            requestBody?: {
                content: {
                    "application/json": {
                        description?: string | null;
                        completion_snapshot_items: components["schemas"]["Organization::CreateCompletionSnapshotItemDto"][];
                    };
                };
            };
            responses: {
                /** @description completion snapshot successfully created */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            result: components["schemas"]["Organization::CompletionSnapshotDto"];
                        };
                    };
                };
                /** @description unauthorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description forbiden */
                403: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description unprocessable entity */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/completion_snapshots/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: number;
            };
            cookie?: never;
        };
        /** Show completion snapshot details */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description show completion_snapshot */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            result: components["schemas"]["Organization::CompletionSnapshotDto"];
                        };
                    };
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** List all the project's versions */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                    project_id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description list company's projects */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            results: components["schemas"]["Organization::ProjectVersionIndexResponseProjectDto"][];
                        };
                    };
                };
                /** @description not authorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Show the project version details */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                    project_id: number;
                    id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description show project version details */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            result: components["schemas"]["Organization::ProjectVersionShowResponseProjectVersionDto"];
                        };
                    };
                };
                /** @description not authorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/projects": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** List all the company's project */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description list company's projects */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            results: components["schemas"]["Organization::ProjectIndexResponseProjectDto"][];
                        };
                    };
                };
                /** @description not authorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        put?: never;
        /** Creates a new project and its descendants */
        post: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                };
                cookie?: never;
            };
            requestBody?: {
                content: {
                    "application/json": {
                        name: string;
                        description?: string | null;
                        client_id: number;
                        retention_guarantee_rate: number;
                        items: components["schemas"]["Organization::CreateProjecItemDto"][] | components["schemas"]["Organization::CreateProjectItemGroupDto"][];
                    };
                };
            };
            responses: {
                /** @description project created */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            id: number;
                            name: string;
                            description?: string | null;
                            client_id: number;
                            versions: components["schemas"]["Organization::ProjectDtoProjectVersionDto"][];
                        };
                    };
                };
                /** @description not authorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description unprocessable entity */
                422: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": components["schemas"]["error"];
                    };
                };
            };
        };
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/v1/organization/companies/{company_id}/projects/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Show the project details */
        get: {
            parameters: {
                query?: never;
                header?: never;
                path: {
                    company_id: number;
                    id: number;
                };
                cookie?: never;
            };
            requestBody?: never;
            responses: {
                /** @description list company's projects */
                200: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content: {
                        "application/json": {
                            result: components["schemas"]["Organization::ProjectShowResponseProjectDto"];
                        };
                    };
                };
                /** @description not authorised */
                401: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
                /** @description not found */
                404: {
                    headers: {
                        [name: string]: unknown;
                    };
                    content?: never;
                };
            };
        };
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
}
export type webhooks = Record<string, never>;
export interface components {
    schemas: {
        client: {
            id: number;
            name: string;
            registration_number: string;
            email: string;
            phone: string;
            address_city: string;
            address_street: string;
            address_zipcode: string;
        };
        create_project_with_item_groups: {
            name: string;
            description?: string;
            client_id?: string;
            project_versions_attributes: {
                retention_guarantee_rate: number;
                item_groups_attributes: {
                    name: string;
                    description?: string;
                    position: number;
                    items_attributes: {
                        name: string;
                        description?: string;
                        position: number;
                        quantity: number;
                        unit_price_cents: number;
                        unit: string;
                    }[];
                }[];
            }[];
        };
        create_project_with_items: {
            name: string;
            client_id?: string;
            description?: string;
            project_versions_attributes: {
                retention_guarantee_rate: number;
                items_attributes: {
                    name: string;
                    description?: string;
                    position: number;
                    quantity: number;
                    unit_price_cents: number;
                    unit: string;
                }[];
            }[];
        };
        error: {
            error: {
                status: string;
                code: number;
                message: string;
                details: Record<string, never>;
            };
        };
        "Organization::CompletionSnapshotDtoItemDto": {
            /** Format: decimal */
            completion_percentage: string;
            item_id: number;
        };
        "Organization::CompletionSnapshotDto": {
            id: number;
            description?: string | null;
            completion_snapshot_items: components["schemas"]["Organization::CompletionSnapshotDtoItemDto"][];
        };
        "Organization::CreateCompletionSnapshotItemDto": {
            completion_percentage: string;
            item_id: number;
        };
        "Organization::CreateCompletionSnapshotDto": {
            description?: string | null;
            completion_snapshot_items: components["schemas"]["Organization::CreateCompletionSnapshotItemDto"][];
        };
        "Organization::CreateProjecItemDto": {
            name: string;
            description?: string | null;
            position: number;
            unit: string;
            unit_price_cents: number;
            quantity: number;
        };
        "Organization::CreateProjectItemGroupDto": {
            name: string;
            description?: string | null;
            position: number;
            items: components["schemas"]["Organization::CreateProjecItemDto"][];
        };
        "Organization::CreateProjectDto": {
            name: string;
            description?: string | null;
            client_id: number;
            retention_guarantee_rate: number;
            items: components["schemas"]["Organization::CreateProjecItemDto"][] | components["schemas"]["Organization::CreateProjectItemGroupDto"][];
        };
        "Organization::ProjectDtoItemDto": {
            id: number;
            position: number;
            name: string;
            description?: string | null;
            quantity: number;
            unit: string;
            unit_price_cents: number;
        };
        "Organization::ProjectDtoItemGroupDto": {
            id: number;
            name: string;
            description?: string | null;
            position: number;
            items: components["schemas"]["Organization::ProjectDtoItemDto"][];
        };
        "Organization::ProjectDtoProjectVersionDto": {
            id: number;
            retention_rate_guarantee: number;
            number: number;
            items: components["schemas"]["Organization::ProjectDtoItemDto"][] | components["schemas"]["Organization::ProjectDtoItemGroupDto"][];
        };
        "Organization::ProjectDto": {
            id: number;
            name: string;
            description?: string | null;
            client_id: number;
            versions: components["schemas"]["Organization::ProjectDtoProjectVersionDto"][];
        };
        "Organization::ProjectIndexResponseProjectClientDto": {
            id: number;
            name: string;
        };
        "Organization::ProjectIndexResponseProjectDto": {
            id: number;
            name: string;
            description?: string | null;
            client: components["schemas"]["Organization::ProjectIndexResponseProjectClientDto"];
            /** @enum {string} */
            status: "new" | "invoicing_in_progress" | "invoiced" | "canceled";
        };
        "Organization::ProjectIndexResponseDto": {
            results: components["schemas"]["Organization::ProjectIndexResponseProjectDto"][];
        };
        "Organization::ProjectShowResponseProjectClientDto": {
            id: number;
            name: string;
            email: string;
            phone: string;
        };
        "Organization::ProjectShowResponseProjectItemDto": {
            id: number;
            position: number;
            name: string;
            description?: string | null;
            quantity: number;
            unit: string;
            unit_price_cents: number;
        };
        "Organization::ProjectShowResponseProjectItemGroupDto": {
            id: number;
            position: number;
            name: string;
            description?: string | null;
            grouped_items: components["schemas"]["Organization::ProjectShowResponseProjectItemDto"][];
        };
        "Organization::ProjectShowResponseProjectLastVersionDto": {
            id: number;
            number: number;
            /** Format: date-time */
            created_at: string;
            ungrouped_items: components["schemas"]["Organization::ProjectShowResponseProjectItemDto"][];
            item_groups: components["schemas"]["Organization::ProjectShowResponseProjectItemGroupDto"][];
        };
        "Organization::ProjectShowResponseProjectDto": {
            id: number;
            name: string;
            description?: string | null;
            client: components["schemas"]["Organization::ProjectShowResponseProjectClientDto"];
            /** @enum {string} */
            status: "new" | "invoicing_in_progress" | "invoiced" | "canceled";
            last_version: components["schemas"]["Organization::ProjectShowResponseProjectLastVersionDto"];
        };
        "Organization::ProjectShowResponseDto": {
            result: components["schemas"]["Organization::ProjectShowResponseProjectDto"];
        };
        "Organization::ProjectVersionIndexResponseProjectDto": {
            id: number;
            number: number;
            /** Format: date-time */
            created_at: string;
        };
        "Organization::ProjectVersionIndexResponseDto": {
            results: components["schemas"]["Organization::ProjectVersionIndexResponseProjectDto"][];
        };
        "Organization::ProjectVersionShowProjectVersionItemDto": {
            id: number;
            position: number;
            name: string;
            description?: string | null;
            quantity: number;
            unit: string;
            unit_price_cents: number;
        };
        "Organization::ProjectVersionShowProjectVersionItemGroupDto": {
            id: number;
            position: number;
            name: string;
            description?: string | null;
            grouped_items: components["schemas"]["Organization::ProjectVersionShowProjectVersionItemDto"][];
        };
        "Organization::ProjectVersionShowResponseProjectVersionDto": {
            id: number;
            number: number;
            is_last_version: boolean;
            /** Format: date-time */
            created_at: string;
            retention_guarantee_rate: number;
            ungrouped_items: components["schemas"]["Organization::ProjectVersionShowProjectVersionItemDto"][];
            item_groups: components["schemas"]["Organization::ProjectVersionShowProjectVersionItemGroupDto"][];
        };
        "Organization::ProjectVersionShowResponseDto": {
            result: components["schemas"]["Organization::ProjectVersionShowResponseProjectVersionDto"];
        };
        "Organization::ShowCompletionSnapshotResponseDto": {
            result: components["schemas"]["Organization::CompletionSnapshotDto"];
        };
    };
    responses: never;
    parameters: never;
    requestBodies: never;
    headers: never;
    pathItems: never;
}
export type $defs = Record<string, never>;
export type operations = Record<string, never>;
