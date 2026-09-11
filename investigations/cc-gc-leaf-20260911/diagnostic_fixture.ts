function allocating(text: string): string {
    return text.slice(1) + "!";
}
function dynamicCall(fn: any, value: any): any {
    return fn(value);
}
function exercise(seed: number): string {
    const fresh: any = { text: "seed", value: seed };
    fresh.text = "kept";
    fresh.value = Number.isSafeInteger(seed) ? seed : 0;
    const increment: any = (n: number) => n + 1;
    return allocating(fresh.text) + ":" + dynamicCall(increment, fresh.value);
}
console.log(exercise(7));
