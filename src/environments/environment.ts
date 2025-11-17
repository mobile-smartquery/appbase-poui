// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: false,

  apiEndpointPath: 'http://protheusawsmobile.ddns.net:8080/rest',

  username: '',
  password: '',

  apiBaseUrl: 'http://protheusawsmobile.ddns.net:8080/rest',
  oauthTokenUrl:
    'http://protheusawsmobile.ddns.net:8080/rest/api/oauth2/v1/token',
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
