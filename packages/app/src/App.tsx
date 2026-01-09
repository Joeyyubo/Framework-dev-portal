import { createApp } from '@backstage/app-defaults';
import { AlertDisplay, OAuthRequestDialog } from '@backstage/core-components';
import { ApiExplorerPage } from '@backstage/plugin-api-docs';
import {
  CatalogEntityPage,
  CatalogIndexPage,
} from '@backstage/plugin-catalog';
import { CatalogImportPage } from '@backstage/plugin-catalog-import';
import { ScaffolderPage } from '@backstage/plugin-scaffolder';
import { SearchPage } from '@backstage/plugin-search';
import { UserSettingsPage } from '@backstage/plugin-user-settings';
import React from 'react';
import { Navigate, Route } from 'react-router-dom';
import { FlatRoutes } from '@backstage/core-app-api';
import { apis } from './apis';

// Ensure createApp and related calls are only made once, even with hot reloading
// Use global to persist across hot reloads
declare global {
  interface Window {
    __BACKSTAGE_APP_INSTANCE__?: ReturnType<typeof createApp>;
    __BACKSTAGE_APP_PROVIDER__?: React.ComponentType;
    __BACKSTAGE_APP_ROUTER__?: React.ComponentType;
    __BACKSTAGE_APP_COMPONENT__?: React.ComponentType;
  }
}

function getApp() {
  // Use window global if available (browser), otherwise create new
  if (typeof window !== 'undefined' && window.__BACKSTAGE_APP_INSTANCE__) {
    return window.__BACKSTAGE_APP_INSTANCE__;
  }
  
  const appInstance = createApp({
    apis: apis, // Import APIs from apis.ts (app-defaults also includes default APIs)
    // bindRoutes is optional - scaffolder routes are automatically available
    // Remove bindRoutes if it causes errors with external route keys
  });
  
  if (typeof window !== 'undefined') {
    window.__BACKSTAGE_APP_INSTANCE__ = appInstance;
  }
  
  return appInstance;
}

function getAppProvider() {
  if (typeof window !== 'undefined' && window.__BACKSTAGE_APP_PROVIDER__) {
    return window.__BACKSTAGE_APP_PROVIDER__;
  }
  
  const app = getApp();
  const provider = app.getProvider();
  
  if (typeof window !== 'undefined') {
    window.__BACKSTAGE_APP_PROVIDER__ = provider;
  }
  
  return provider;
}

function getAppRouter() {
  if (typeof window !== 'undefined' && window.__BACKSTAGE_APP_ROUTER__) {
    return window.__BACKSTAGE_APP_ROUTER__;
  }
  
  const app = getApp();
  const router = app.getRouter();
  
  if (typeof window !== 'undefined') {
    window.__BACKSTAGE_APP_ROUTER__ = router;
  }
  
  return router;
}

const routes = (
  <FlatRoutes>
    <Route path="/" element={<Navigate to="catalog" />} />
    <Route path="/catalog" element={<CatalogIndexPage />} />
    <Route
      path="/catalog/:namespace/:kind/:name"
      element={<CatalogEntityPage />}
    />
    <Route path="/docs" element={<Navigate to="/docs/default/component" />} />
    <Route path="/create" element={<ScaffolderPage />} />
    <Route path="/api-docs" element={<ApiExplorerPage />} />
    <Route path="/settings" element={<UserSettingsPage />} />
    <Route path="/catalog-import" element={<CatalogImportPage />} />
    <Route path="/search" element={<SearchPage />} />
  </FlatRoutes>
);

// Build the app component using getProvider() and getRouter()
// Note: Do NOT call createRoot() if using getProvider() - they are mutually exclusive
function getAppComponent() {
  if (typeof window !== 'undefined' && window.__BACKSTAGE_APP_COMPONENT__) {
    return window.__BACKSTAGE_APP_COMPONENT__;
  }
  
  const AppProvider = getAppProvider();
  const AppRouter = getAppRouter();
  
  const AppComponent: React.FC = () => (
    <AppProvider>
      <AlertDisplay />
      <OAuthRequestDialog />
      <AppRouter>
        {routes}
      </AppRouter>
    </AppProvider>
  );
  
  if (typeof window !== 'undefined') {
    window.__BACKSTAGE_APP_COMPONENT__ = AppComponent;
  }
  
  return AppComponent;
}

const App = getAppComponent();
export default App;

