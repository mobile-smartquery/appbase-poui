export const environment = {
  production: false,

  // Development (local) should use the SPA proxy at `/rest`.
  apiEndpointPath: '/rest',
  apiBaseUrl: '/rest',

  // Token URL for local dev (goes through dev proxy)
  oauthTokenUrl: '/rest/api/oauth2/v1/token',

  // Optional local JSON menu server used in some branches
  apiMenuUrl: 'http://localhost:3000/menu',

  username: '',
  password: '',
};
