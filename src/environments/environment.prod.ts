export const environment = {
  production: true,

  apiEndpointPath: 'http://protheusawsmobile.ddns.net:8080/rest',
  // In production the frontend calls the serverless proxy on Vercel.
  apiBaseUrl: '/rest',
  oauthTokenUrl: '/api/rest/api/oauth2/v1/token',

  // Remote branch had an apiMenuUrl pointing to an external JSON service;
  // preserve it as optional config in production.
  apiMenuUrl: 'https://api-json-brown.vercel.app/menu',

  username: '',
  password: '',
};
