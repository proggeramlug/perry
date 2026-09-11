# Diagnostic bitcode payload correction

The first snapshot writer passed `MemoryBuffer::as_slice()` to the file writer. Inkwell 0.9.0 explicitly includes the API terminator in that slice and in `get_size()` (`memory_buffer.rs:135–151`; the latter is `LLVMGetBufferSize + 1`). The file therefore contained one extra byte. The coordinator observed LLVM 22 reject that file and accept a copied file with exactly the extra byte removed. This was a diagnostic transport error, not evidence about GC-call treatment.

The correction routes all four snapshot call sites through `snapshot_bitcode`. Its payload is exactly `as_slice()[..get_size()-1]`. It excludes one API terminator and never trims real trailing zero bytes. Passes, runtime behavior, object emission and all leaf classifications remain unchanged. The standalone callsite analyzer is unchanged.

The original test compared the saved file to the same invalid slice, so it could not catch the error. The strengthened existing test now opens each actual saved file with LLVM's file-backed MemoryBuffer, reparses it as bitcode, verifies the module, and checks its real barrier call. It also writes the old appended-terminator recipe as a separate file and requires the parser to reject it. An independent buffer carrying two real trailing zeros verifies that only the API byte is excluded. The prior input-fixture NUL correction is retained.

Three diagnostic-module tests remain; this lane ran no Cargo, LLVM execution or box job. Rustfmt and diff whitespace checks passed. The coordinator owns compilation and execution. `before.json` preserves the exact two pre-correction files; `correction.patch` and `receipt.json` bind the narrow change.
