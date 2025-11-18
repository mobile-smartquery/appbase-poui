export const environment = {
  production: false,

  apiEndpointPath: 'http://protheusawsmobile.ddns.net:8080/rest',
  // Development (local) should use the SPA proxy at `/rest`.
  apiBaseUrl: '/rest',

  // Token URL for local dev (goes through dev proxy)
  oauthTokenUrl: '/rest/api/oauth2/v1/token',

  // Optional local JSON menu server used in some branches
  apiMenuUrl: 'http://localhost:3000/menu',

  username: '',
  password: '',
};
