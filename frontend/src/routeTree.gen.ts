/* eslint-disable */

// @ts-nocheck

// noinspection JSUnusedGlobalSymbols

// This file was automatically generated by TanStack Router.
// You should NOT make any changes in this file as it will be overwritten.
// Additionally, you should also exclude this file from your linter and/or formatter to prevent it from being checked or modified.

// Import Routes

import { Route as rootRoute } from './routes/__root'
import { Route as AuthenticatedImport } from './routes/_authenticated'
import { Route as AuthenticatedIndexImport } from './routes/_authenticated/index'
import { Route as AuthLoginImport } from './routes/auth/login'
import { Route as AuthenticatedCompaniesCompanyIdImport } from './routes/_authenticated/companies/$companyId'
import { Route as AuthenticatedCompaniesCompanyIdIndexImport } from './routes/_authenticated/companies/$companyId/index'
import { Route as AuthenticatedCompaniesCompanyIdQuotesIndexImport } from './routes/_authenticated/companies/$companyId/quotes/index'
import { Route as AuthenticatedCompaniesCompanyIdOrdersIndexImport } from './routes/_authenticated/companies/$companyId/orders/index'
import { Route as AuthenticatedCompaniesCompanyIdInvoicesIndexImport } from './routes/_authenticated/companies/$companyId/invoices/index'
import { Route as AuthenticatedCompaniesCompanyIdClientsIndexImport } from './routes/_authenticated/companies/$companyId/clients/index'
import { Route as AuthenticatedCompaniesCompanyIdQuotesNewImport } from './routes/_authenticated/companies/$companyId/quotes/new'
import { Route as AuthenticatedCompaniesCompanyIdOrdersNewImport } from './routes/_authenticated/companies/$companyId/orders/new'
import { Route as AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdImport } from './routes/_authenticated/companies/$companyId/invoices/$invoiceId'
import { Route as AuthenticatedCompaniesCompanyIdClientsNewImport } from './routes/_authenticated/companies/$companyId/clients/new'
import { Route as AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexImport } from './routes/_authenticated/companies/$companyId/quotes/$quoteId/index'
import { Route as AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexImport } from './routes/_authenticated/companies/$companyId/orders/$orderId/index'
import { Route as AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewImport } from './routes/_authenticated/companies/$companyId/orders/$orderId/invoices/new'
import { Route as AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateImport } from './routes/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'

// Create/Update Routes

const AuthenticatedRoute = AuthenticatedImport.update({
  id: '/_authenticated',
  getParentRoute: () => rootRoute,
} as any)

const AuthenticatedIndexRoute = AuthenticatedIndexImport.update({
  id: '/',
  path: '/',
  getParentRoute: () => AuthenticatedRoute,
} as any)

const AuthLoginRoute = AuthLoginImport.update({
  id: '/auth/login',
  path: '/auth/login',
  getParentRoute: () => rootRoute,
} as any)

const AuthenticatedCompaniesCompanyIdRoute =
  AuthenticatedCompaniesCompanyIdImport.update({
    id: '/companies/$companyId',
    path: '/companies/$companyId',
    getParentRoute: () => AuthenticatedRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdIndexRoute =
  AuthenticatedCompaniesCompanyIdIndexImport.update({
    id: '/',
    path: '/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdQuotesIndexRoute =
  AuthenticatedCompaniesCompanyIdQuotesIndexImport.update({
    id: '/quotes/',
    path: '/quotes/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdOrdersIndexRoute =
  AuthenticatedCompaniesCompanyIdOrdersIndexImport.update({
    id: '/orders/',
    path: '/orders/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdInvoicesIndexRoute =
  AuthenticatedCompaniesCompanyIdInvoicesIndexImport.update({
    id: '/invoices/',
    path: '/invoices/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdClientsIndexRoute =
  AuthenticatedCompaniesCompanyIdClientsIndexImport.update({
    id: '/clients/',
    path: '/clients/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdQuotesNewRoute =
  AuthenticatedCompaniesCompanyIdQuotesNewImport.update({
    id: '/quotes/new',
    path: '/quotes/new',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdOrdersNewRoute =
  AuthenticatedCompaniesCompanyIdOrdersNewImport.update({
    id: '/orders/new',
    path: '/orders/new',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute =
  AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdImport.update({
    id: '/invoices/$invoiceId',
    path: '/invoices/$invoiceId',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdClientsNewRoute =
  AuthenticatedCompaniesCompanyIdClientsNewImport.update({
    id: '/clients/new',
    path: '/clients/new',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute =
  AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexImport.update({
    id: '/quotes/$quoteId/',
    path: '/quotes/$quoteId/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute =
  AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexImport.update({
    id: '/orders/$orderId/',
    path: '/orders/$orderId/',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute =
  AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewImport.update({
    id: '/orders/$orderId/invoices/new',
    path: '/orders/$orderId/invoices/new',
    getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
  } as any)

const AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute =
  AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateImport.update(
    {
      id: '/orders/$orderId/invoices/$invoiceId/update',
      path: '/orders/$orderId/invoices/$invoiceId/update',
      getParentRoute: () => AuthenticatedCompaniesCompanyIdRoute,
    } as any,
  )

// Populate the FileRoutesByPath interface

declare module '@tanstack/react-router' {
  interface FileRoutesByPath {
    '/_authenticated': {
      id: '/_authenticated'
      path: ''
      fullPath: ''
      preLoaderRoute: typeof AuthenticatedImport
      parentRoute: typeof rootRoute
    }
    '/auth/login': {
      id: '/auth/login'
      path: '/auth/login'
      fullPath: '/auth/login'
      preLoaderRoute: typeof AuthLoginImport
      parentRoute: typeof rootRoute
    }
    '/_authenticated/': {
      id: '/_authenticated/'
      path: '/'
      fullPath: '/'
      preLoaderRoute: typeof AuthenticatedIndexImport
      parentRoute: typeof AuthenticatedImport
    }
    '/_authenticated/companies/$companyId': {
      id: '/_authenticated/companies/$companyId'
      path: '/companies/$companyId'
      fullPath: '/companies/$companyId'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdImport
      parentRoute: typeof AuthenticatedImport
    }
    '/_authenticated/companies/$companyId/': {
      id: '/_authenticated/companies/$companyId/'
      path: '/'
      fullPath: '/companies/$companyId/'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/clients/new': {
      id: '/_authenticated/companies/$companyId/clients/new'
      path: '/clients/new'
      fullPath: '/companies/$companyId/clients/new'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdClientsNewImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/invoices/$invoiceId': {
      id: '/_authenticated/companies/$companyId/invoices/$invoiceId'
      path: '/invoices/$invoiceId'
      fullPath: '/companies/$companyId/invoices/$invoiceId'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/orders/new': {
      id: '/_authenticated/companies/$companyId/orders/new'
      path: '/orders/new'
      fullPath: '/companies/$companyId/orders/new'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdOrdersNewImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/quotes/new': {
      id: '/_authenticated/companies/$companyId/quotes/new'
      path: '/quotes/new'
      fullPath: '/companies/$companyId/quotes/new'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdQuotesNewImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/clients/': {
      id: '/_authenticated/companies/$companyId/clients/'
      path: '/clients'
      fullPath: '/companies/$companyId/clients'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdClientsIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/invoices/': {
      id: '/_authenticated/companies/$companyId/invoices/'
      path: '/invoices'
      fullPath: '/companies/$companyId/invoices'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdInvoicesIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/orders/': {
      id: '/_authenticated/companies/$companyId/orders/'
      path: '/orders'
      fullPath: '/companies/$companyId/orders'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdOrdersIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/quotes/': {
      id: '/_authenticated/companies/$companyId/quotes/'
      path: '/quotes'
      fullPath: '/companies/$companyId/quotes'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdQuotesIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/orders/$orderId/': {
      id: '/_authenticated/companies/$companyId/orders/$orderId/'
      path: '/orders/$orderId'
      fullPath: '/companies/$companyId/orders/$orderId'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/quotes/$quoteId/': {
      id: '/_authenticated/companies/$companyId/quotes/$quoteId/'
      path: '/quotes/$quoteId'
      fullPath: '/companies/$companyId/quotes/$quoteId'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/orders/$orderId/invoices/new': {
      id: '/_authenticated/companies/$companyId/orders/$orderId/invoices/new'
      path: '/orders/$orderId/invoices/new'
      fullPath: '/companies/$companyId/orders/$orderId/invoices/new'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
    '/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update': {
      id: '/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'
      path: '/orders/$orderId/invoices/$invoiceId/update'
      fullPath: '/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'
      preLoaderRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateImport
      parentRoute: typeof AuthenticatedCompaniesCompanyIdImport
    }
  }
}

// Create and export the route tree

interface AuthenticatedCompaniesCompanyIdRouteChildren {
  AuthenticatedCompaniesCompanyIdIndexRoute: typeof AuthenticatedCompaniesCompanyIdIndexRoute
  AuthenticatedCompaniesCompanyIdClientsNewRoute: typeof AuthenticatedCompaniesCompanyIdClientsNewRoute
  AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute: typeof AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute
  AuthenticatedCompaniesCompanyIdOrdersNewRoute: typeof AuthenticatedCompaniesCompanyIdOrdersNewRoute
  AuthenticatedCompaniesCompanyIdQuotesNewRoute: typeof AuthenticatedCompaniesCompanyIdQuotesNewRoute
  AuthenticatedCompaniesCompanyIdClientsIndexRoute: typeof AuthenticatedCompaniesCompanyIdClientsIndexRoute
  AuthenticatedCompaniesCompanyIdInvoicesIndexRoute: typeof AuthenticatedCompaniesCompanyIdInvoicesIndexRoute
  AuthenticatedCompaniesCompanyIdOrdersIndexRoute: typeof AuthenticatedCompaniesCompanyIdOrdersIndexRoute
  AuthenticatedCompaniesCompanyIdQuotesIndexRoute: typeof AuthenticatedCompaniesCompanyIdQuotesIndexRoute
  AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute
  AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute: typeof AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute
  AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute
  AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute: typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute
}

const AuthenticatedCompaniesCompanyIdRouteChildren: AuthenticatedCompaniesCompanyIdRouteChildren =
  {
    AuthenticatedCompaniesCompanyIdIndexRoute:
      AuthenticatedCompaniesCompanyIdIndexRoute,
    AuthenticatedCompaniesCompanyIdClientsNewRoute:
      AuthenticatedCompaniesCompanyIdClientsNewRoute,
    AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute:
      AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute,
    AuthenticatedCompaniesCompanyIdOrdersNewRoute:
      AuthenticatedCompaniesCompanyIdOrdersNewRoute,
    AuthenticatedCompaniesCompanyIdQuotesNewRoute:
      AuthenticatedCompaniesCompanyIdQuotesNewRoute,
    AuthenticatedCompaniesCompanyIdClientsIndexRoute:
      AuthenticatedCompaniesCompanyIdClientsIndexRoute,
    AuthenticatedCompaniesCompanyIdInvoicesIndexRoute:
      AuthenticatedCompaniesCompanyIdInvoicesIndexRoute,
    AuthenticatedCompaniesCompanyIdOrdersIndexRoute:
      AuthenticatedCompaniesCompanyIdOrdersIndexRoute,
    AuthenticatedCompaniesCompanyIdQuotesIndexRoute:
      AuthenticatedCompaniesCompanyIdQuotesIndexRoute,
    AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute:
      AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute,
    AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute:
      AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute,
    AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute:
      AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute,
    AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute:
      AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute,
  }

const AuthenticatedCompaniesCompanyIdRouteWithChildren =
  AuthenticatedCompaniesCompanyIdRoute._addFileChildren(
    AuthenticatedCompaniesCompanyIdRouteChildren,
  )

interface AuthenticatedRouteChildren {
  AuthenticatedIndexRoute: typeof AuthenticatedIndexRoute
  AuthenticatedCompaniesCompanyIdRoute: typeof AuthenticatedCompaniesCompanyIdRouteWithChildren
}

const AuthenticatedRouteChildren: AuthenticatedRouteChildren = {
  AuthenticatedIndexRoute: AuthenticatedIndexRoute,
  AuthenticatedCompaniesCompanyIdRoute:
    AuthenticatedCompaniesCompanyIdRouteWithChildren,
}

const AuthenticatedRouteWithChildren = AuthenticatedRoute._addFileChildren(
  AuthenticatedRouteChildren,
)

export interface FileRoutesByFullPath {
  '': typeof AuthenticatedRouteWithChildren
  '/auth/login': typeof AuthLoginRoute
  '/': typeof AuthenticatedIndexRoute
  '/companies/$companyId': typeof AuthenticatedCompaniesCompanyIdRouteWithChildren
  '/companies/$companyId/': typeof AuthenticatedCompaniesCompanyIdIndexRoute
  '/companies/$companyId/clients/new': typeof AuthenticatedCompaniesCompanyIdClientsNewRoute
  '/companies/$companyId/invoices/$invoiceId': typeof AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute
  '/companies/$companyId/orders/new': typeof AuthenticatedCompaniesCompanyIdOrdersNewRoute
  '/companies/$companyId/quotes/new': typeof AuthenticatedCompaniesCompanyIdQuotesNewRoute
  '/companies/$companyId/clients': typeof AuthenticatedCompaniesCompanyIdClientsIndexRoute
  '/companies/$companyId/invoices': typeof AuthenticatedCompaniesCompanyIdInvoicesIndexRoute
  '/companies/$companyId/orders': typeof AuthenticatedCompaniesCompanyIdOrdersIndexRoute
  '/companies/$companyId/quotes': typeof AuthenticatedCompaniesCompanyIdQuotesIndexRoute
  '/companies/$companyId/orders/$orderId': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute
  '/companies/$companyId/quotes/$quoteId': typeof AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute
  '/companies/$companyId/orders/$orderId/invoices/new': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute
  '/companies/$companyId/orders/$orderId/invoices/$invoiceId/update': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute
}

export interface FileRoutesByTo {
  '/auth/login': typeof AuthLoginRoute
  '/': typeof AuthenticatedIndexRoute
  '/companies/$companyId': typeof AuthenticatedCompaniesCompanyIdIndexRoute
  '/companies/$companyId/clients/new': typeof AuthenticatedCompaniesCompanyIdClientsNewRoute
  '/companies/$companyId/invoices/$invoiceId': typeof AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute
  '/companies/$companyId/orders/new': typeof AuthenticatedCompaniesCompanyIdOrdersNewRoute
  '/companies/$companyId/quotes/new': typeof AuthenticatedCompaniesCompanyIdQuotesNewRoute
  '/companies/$companyId/clients': typeof AuthenticatedCompaniesCompanyIdClientsIndexRoute
  '/companies/$companyId/invoices': typeof AuthenticatedCompaniesCompanyIdInvoicesIndexRoute
  '/companies/$companyId/orders': typeof AuthenticatedCompaniesCompanyIdOrdersIndexRoute
  '/companies/$companyId/quotes': typeof AuthenticatedCompaniesCompanyIdQuotesIndexRoute
  '/companies/$companyId/orders/$orderId': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute
  '/companies/$companyId/quotes/$quoteId': typeof AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute
  '/companies/$companyId/orders/$orderId/invoices/new': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute
  '/companies/$companyId/orders/$orderId/invoices/$invoiceId/update': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute
}

export interface FileRoutesById {
  __root__: typeof rootRoute
  '/_authenticated': typeof AuthenticatedRouteWithChildren
  '/auth/login': typeof AuthLoginRoute
  '/_authenticated/': typeof AuthenticatedIndexRoute
  '/_authenticated/companies/$companyId': typeof AuthenticatedCompaniesCompanyIdRouteWithChildren
  '/_authenticated/companies/$companyId/': typeof AuthenticatedCompaniesCompanyIdIndexRoute
  '/_authenticated/companies/$companyId/clients/new': typeof AuthenticatedCompaniesCompanyIdClientsNewRoute
  '/_authenticated/companies/$companyId/invoices/$invoiceId': typeof AuthenticatedCompaniesCompanyIdInvoicesInvoiceIdRoute
  '/_authenticated/companies/$companyId/orders/new': typeof AuthenticatedCompaniesCompanyIdOrdersNewRoute
  '/_authenticated/companies/$companyId/quotes/new': typeof AuthenticatedCompaniesCompanyIdQuotesNewRoute
  '/_authenticated/companies/$companyId/clients/': typeof AuthenticatedCompaniesCompanyIdClientsIndexRoute
  '/_authenticated/companies/$companyId/invoices/': typeof AuthenticatedCompaniesCompanyIdInvoicesIndexRoute
  '/_authenticated/companies/$companyId/orders/': typeof AuthenticatedCompaniesCompanyIdOrdersIndexRoute
  '/_authenticated/companies/$companyId/quotes/': typeof AuthenticatedCompaniesCompanyIdQuotesIndexRoute
  '/_authenticated/companies/$companyId/orders/$orderId/': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdIndexRoute
  '/_authenticated/companies/$companyId/quotes/$quoteId/': typeof AuthenticatedCompaniesCompanyIdQuotesQuoteIdIndexRoute
  '/_authenticated/companies/$companyId/orders/$orderId/invoices/new': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesNewRoute
  '/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update': typeof AuthenticatedCompaniesCompanyIdOrdersOrderIdInvoicesInvoiceIdUpdateRoute
}

export interface FileRouteTypes {
  fileRoutesByFullPath: FileRoutesByFullPath
  fullPaths:
    | ''
    | '/auth/login'
    | '/'
    | '/companies/$companyId'
    | '/companies/$companyId/'
    | '/companies/$companyId/clients/new'
    | '/companies/$companyId/invoices/$invoiceId'
    | '/companies/$companyId/orders/new'
    | '/companies/$companyId/quotes/new'
    | '/companies/$companyId/clients'
    | '/companies/$companyId/invoices'
    | '/companies/$companyId/orders'
    | '/companies/$companyId/quotes'
    | '/companies/$companyId/orders/$orderId'
    | '/companies/$companyId/quotes/$quoteId'
    | '/companies/$companyId/orders/$orderId/invoices/new'
    | '/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'
  fileRoutesByTo: FileRoutesByTo
  to:
    | '/auth/login'
    | '/'
    | '/companies/$companyId'
    | '/companies/$companyId/clients/new'
    | '/companies/$companyId/invoices/$invoiceId'
    | '/companies/$companyId/orders/new'
    | '/companies/$companyId/quotes/new'
    | '/companies/$companyId/clients'
    | '/companies/$companyId/invoices'
    | '/companies/$companyId/orders'
    | '/companies/$companyId/quotes'
    | '/companies/$companyId/orders/$orderId'
    | '/companies/$companyId/quotes/$quoteId'
    | '/companies/$companyId/orders/$orderId/invoices/new'
    | '/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'
  id:
    | '__root__'
    | '/_authenticated'
    | '/auth/login'
    | '/_authenticated/'
    | '/_authenticated/companies/$companyId'
    | '/_authenticated/companies/$companyId/'
    | '/_authenticated/companies/$companyId/clients/new'
    | '/_authenticated/companies/$companyId/invoices/$invoiceId'
    | '/_authenticated/companies/$companyId/orders/new'
    | '/_authenticated/companies/$companyId/quotes/new'
    | '/_authenticated/companies/$companyId/clients/'
    | '/_authenticated/companies/$companyId/invoices/'
    | '/_authenticated/companies/$companyId/orders/'
    | '/_authenticated/companies/$companyId/quotes/'
    | '/_authenticated/companies/$companyId/orders/$orderId/'
    | '/_authenticated/companies/$companyId/quotes/$quoteId/'
    | '/_authenticated/companies/$companyId/orders/$orderId/invoices/new'
    | '/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update'
  fileRoutesById: FileRoutesById
}

export interface RootRouteChildren {
  AuthenticatedRoute: typeof AuthenticatedRouteWithChildren
  AuthLoginRoute: typeof AuthLoginRoute
}

const rootRouteChildren: RootRouteChildren = {
  AuthenticatedRoute: AuthenticatedRouteWithChildren,
  AuthLoginRoute: AuthLoginRoute,
}

export const routeTree = rootRoute
  ._addFileChildren(rootRouteChildren)
  ._addFileTypes<FileRouteTypes>()

/* ROUTE_MANIFEST_START
{
  "routes": {
    "__root__": {
      "filePath": "__root.tsx",
      "children": [
        "/_authenticated",
        "/auth/login"
      ]
    },
    "/_authenticated": {
      "filePath": "_authenticated.tsx",
      "children": [
        "/_authenticated/",
        "/_authenticated/companies/$companyId"
      ]
    },
    "/auth/login": {
      "filePath": "auth/login.tsx"
    },
    "/_authenticated/": {
      "filePath": "_authenticated/index.tsx",
      "parent": "/_authenticated"
    },
    "/_authenticated/companies/$companyId": {
      "filePath": "_authenticated/companies/$companyId.tsx",
      "parent": "/_authenticated",
      "children": [
        "/_authenticated/companies/$companyId/",
        "/_authenticated/companies/$companyId/clients/new",
        "/_authenticated/companies/$companyId/invoices/$invoiceId",
        "/_authenticated/companies/$companyId/orders/new",
        "/_authenticated/companies/$companyId/quotes/new",
        "/_authenticated/companies/$companyId/clients/",
        "/_authenticated/companies/$companyId/invoices/",
        "/_authenticated/companies/$companyId/orders/",
        "/_authenticated/companies/$companyId/quotes/",
        "/_authenticated/companies/$companyId/orders/$orderId/",
        "/_authenticated/companies/$companyId/quotes/$quoteId/",
        "/_authenticated/companies/$companyId/orders/$orderId/invoices/new",
        "/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update"
      ]
    },
    "/_authenticated/companies/$companyId/": {
      "filePath": "_authenticated/companies/$companyId/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/clients/new": {
      "filePath": "_authenticated/companies/$companyId/clients/new.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/invoices/$invoiceId": {
      "filePath": "_authenticated/companies/$companyId/invoices/$invoiceId.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/orders/new": {
      "filePath": "_authenticated/companies/$companyId/orders/new.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/quotes/new": {
      "filePath": "_authenticated/companies/$companyId/quotes/new.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/clients/": {
      "filePath": "_authenticated/companies/$companyId/clients/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/invoices/": {
      "filePath": "_authenticated/companies/$companyId/invoices/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/orders/": {
      "filePath": "_authenticated/companies/$companyId/orders/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/quotes/": {
      "filePath": "_authenticated/companies/$companyId/quotes/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/orders/$orderId/": {
      "filePath": "_authenticated/companies/$companyId/orders/$orderId/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/quotes/$quoteId/": {
      "filePath": "_authenticated/companies/$companyId/quotes/$quoteId/index.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/orders/$orderId/invoices/new": {
      "filePath": "_authenticated/companies/$companyId/orders/$orderId/invoices/new.tsx",
      "parent": "/_authenticated/companies/$companyId"
    },
    "/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update": {
      "filePath": "_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/update.tsx",
      "parent": "/_authenticated/companies/$companyId"
    }
  }
}
ROUTE_MANIFEST_END */
