// Accumulator concat: the pattern at iso_miss.ts:205.
// If the engine has cons-strings this is ~O(n); with eager copy it is O(n^2).
function build(n: number): number {
  let s = "";
  for (let i = 0; i < n; i++) {
    s = s + "[" + "abc" + "]";
  }
  return s.length;
}
const sizes: number[] = [2000, 4000, 8000, 16000];
for (let k = 0; k < sizes.length; k++) {
  const t0 = Date.now();
  let acc = 0;
  for (let r = 0; r < 20; r++) acc = acc + build(sizes[k]);
  console.log(sizes[k] + " len=" + acc + " ms=" + (Date.now() - t0));
}
