export const environment = {
  production: true,

  apiEndpointPath: 'http://protheusawsmobile.ddns.net:8080/rest',
  apiBaseUrl: '/rest',
  // In production the frontend should call the serverless function route
  // so the request reaches our proxy on Vercel. Use `/api/rest/...` to
  // target the function directly.
  oauthTokenUrl: '/api/rest/api/oauth2/v1/token',

  username: '',
  password: '',
};
