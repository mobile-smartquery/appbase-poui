// import { Injectable } from '@angular/core';
// import { environment } from '../../../environments/environment';
// import { HttpClient } from '@angular/common/http';
// import { map } from 'rxjs';

// @Injectable({
//   providedIn: 'root',
// })
// export class ContractService {
//   private APIURL = environment.apiUrl;

//   constructor(private http: HttpClient) {}

//   postContract(data: any) {
//     return this.http.post(`${this.APIURL}/DadosPX2`, data).pipe(
//       map((res: any) => {
//         return res;
//       })
//     );
//   }

//   getContract(code?: string) {
//     return this.http.get(`${this.APIURL}/DadosPX2`).pipe(
//       map((res: any) => {
//         return res;
//       })
//     );
//   }
// }
