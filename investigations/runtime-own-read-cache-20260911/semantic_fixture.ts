function read(o: any, k: string): any { return o[k]; }
const o: any = {field: 1, keep: 2};
Object.defineProperty(o, 'field', {value: 7, writable: true, configurable: true});
console.log('data', read(o, 'field'), read(o, 'field'));
o.field = 8;
console.log('updated', read(o, 'field'));
let gets = 0;
Object.defineProperty(o, 'field', {get() { gets++; return 90 + gets; }, configurable: true});
console.log('getter', read(o, 'field'), read(o, 'field'), gets);
Object.defineProperty(o, 'field', {value: 12, writable: true, configurable: true});
console.log('data-again', read(o, 'field'), read(o, 'field'));
Object.setPrototypeOf(o, {field: 44});
delete o.field;
console.log('inherited', read(o, 'field'));
o.field = 15;
console.log('readded', read(o, 'field'));
const wide: any = {};
for (let i = 0; i < 24; i++) wide['k' + i] = i;
console.log('wide', read(wide, 'k23'), read(wide, 'k23'));
for (let n = 0; n < 80; n++) {
  const k = 'k' + (n % 24);
  delete wide[k];
  wide[k] = n;
  if (read(wide, k) !== n) throw new Error('churn value');
}
console.log('churn', read(wide, 'k7'), read(wide, 'k23'));
let traps = 0;
const proxy: any = new Proxy(o, {get(target, key, receiver) { traps++; return Reflect.get(target, key, receiver); }});
console.log('proxy', read(proxy, 'field'), read(proxy, 'field'), traps);
class Values extends Array<number> {}
const values: any = new Values();
values.push(31);
console.log('elements', read(values, '0'), read(values, '0'));
values[0] = 32;
console.log('element-update', read(values, '0'));
const boxed: any = new String('abc');
console.log('string', read(boxed, '0'), read(boxed, '1'));
const frozen: any = Object.freeze({field: 18});
console.log('frozen', read(frozen, 'field'), read(frozen, 'field'));
const keys = ['field', 'keep'];
for (let i = 0; i < 3000; i++) {
  const churn: any = {field: i, keep: i + 1};
  const k = keys[i % 2];
  if (read(churn, k) !== i + (i % 2)) throw new Error('read value');
}
console.log('allocations', read(o, 'field'));
