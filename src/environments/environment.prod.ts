export const environment = {
  production: true,
  // Use Vercel serverless proxy to avoid mixed-content (HTTPS site calling HTTP backend)
  // All frontend HTTP calls should target `/api/rest/...` which is HTTPS and proxied server-side.
  apiEndpointPath: '/api/rest',
  // Keep base as `/rest` for internal composition, but calls go through `apiEndpointPath` above.
  apiBaseUrl: '/rest',
  oauthTokenUrl: '/api/rest/api/oauth2/v1/token',

  // Remote branch had an apiMenuUrl pointing to an external JSON service;
  // preserve it as optional config in production.
  apiMenuUrl: 'https://api-json-brown.vercel.app/menu',

  username: '',
  password: '',
};
