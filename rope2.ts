// Same accumulation, but FORCE the result to be materialized and read,
// so a cons-string engine cannot defer the flatten.
function buildAndRead(n: number): number {
  let s = "";
  for (let i = 0; i < n; i++) s = s + "[" + "abc" + "]";
  let h = 0;
  for (let i = 0; i < s.length; i = i + 997) h = (h + s.charCodeAt(i)) | 0;
  return h;
}
const sizes: number[] = [2000, 4000, 8000, 16000];
for (let k = 0; k < sizes.length; k++) {
  const t0 = Date.now();
  let acc = 0;
  for (let r = 0; r < 20; r++) acc = (acc + buildAndRead(sizes[k])) | 0;
  console.log(sizes[k] + " h=" + acc + " ms=" + (Date.now() - t0));
}
