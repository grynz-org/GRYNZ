# GRYNZ

**Every language. One command.**

GRYNZ is a native command-line companion for developers who work across languages. Written entirely in Zig, it gives source-file builds and execution a consistent entry point while using the compilers and runtimes already installed on your machine.

```sh
grynz build main.rs --out bin
grynz run hello.py
grynz run hello.ts
```

The goal is to grow GRYNZ into a unified toolchain and build companion for polyglot projects and monorepos. The current **v0.7.0-alpha** focuses on individual source files. Project discovery, watch mode, task graphs, and build caching are future work.

[Website source and documentation](https://github.com/grynz-org/grynz-docs) · [Releases](https://github.com/grynz-org/GRYNZ/releases) · [Report an issue](https://github.com/grynz-org/GRYNZ/issues)

## What works today

- Detect a supported language from its file extension.
- Build source files through their native compiler.
- Run supported scripts and bytecode artifacts through their runtime.
- Choose output directories with `--out` where supported by the language adapter.
- Use a single native GRYNZ executable, with no separate runtime required for GRYNZ itself.

**Language toolchains are separate requirements.** GRYNZ does not bundle GCC, Rust, Python, Node.js, or the other tools it invokes. Install the tools you need and make them available on your PATH.

### Language support

Build and run capabilities differ by language; support does not imply identical behavior across ecosystems.

| Language | Build workflow | Run workflow | Required tools |
| --- | --- | --- | --- |
| C | `.c` → native executable | Run the generated executable directly | `gcc` |
| C++ | `.cpp` → native executable | Run the generated executable directly | `g++` |
| Rust | `.rs` → native executable | Run the generated executable directly | `rustc` |
| Go | `.go` → native executable | Run the generated executable directly | `go` |
| Zig | `.zig` → native executable | `grynz run main.zig` | `zig` |
| Java | `.java` → JVM bytecode | `grynz run Main.class --out bin` | `javac`, `java` |
| Kotlin | `.kt` → JVM artifact | `grynz run main.jar` | `kotlinc`, `java` |
| Python | Optional packaging through Nuitka | `grynz run hello.py` | `python`; Nuitka for packaging |
| JavaScript | Optional packaging through `pkg` | `grynz run hello.js` | `node`; `pkg` for packaging |
| TypeScript | `.ts` → JavaScript with `tsc` | `grynz run hello.ts` compiles, then runs | `tsc`, `node` |
| Erlang | `.erl` → BEAM bytecode | `grynz run hello.beam --entry start` | `erlc`, `erl` |
| Elixir | No build dispatch in this alpha | `grynz run hello.exs` or `.ex` | `elixir` |

Python and JavaScript packaging are optional, interactive paths with additional dependencies. The JavaScript packaging adapter currently targets `node18-win-x64`; do not treat it as general cross-platform packaging.

## Get started

Choose a prebuilt binary from [Releases](https://github.com/grynz-org/GRYNZ/releases) or the website repository's [download artifacts](https://github.com/grynz-org/grynz-docs/tree/main/public/downloads). Put the binary in a directory on your PATH. On macOS and Linux, make it executable first:

```sh
chmod +x grynz
grynz --version
```

On Windows, use `grynz.exe` or the available installer. Run `grynz --version` after adding its directory to PATH.

### Build a source file

With Rust installed and a `main.rs` file in the current directory:

```sh
grynz build main.rs --out bin
```

Run the resulting binary directly: `./bin/main` on macOS/Linux or `.\bin\main.exe` on Windows. Native executable execution through `grynz run` is not implemented by the current dispatcher.

### Run a script

With the corresponding runtime installed:

```sh
grynz run hello.py
grynz run hello.js
grynz run hello.exs
```

### Build and run Java

For an un-packaged `Main.java` class:

```sh
grynz build Main.java --out bin
grynz run Main.class --out bin
```

Packaged Java classes must retain their directory structure; `--out` identifies the classpath root.

### Command surface

```text
grynz build <file> [--out <directory>]
grynz run <file> [language-specific options]
grynz --version
```

`--entry <function>` selects an exported Erlang entry function. Flags and output conventions vary by adapter; arbitrary compiler-flag forwarding is not a universal feature yet.

## Build GRYNZ from source

Use a Zig compiler compatible with this codebase's Zig 0.16 APIs. The manifest declares a minimum version of `0.16.0`; the implementation uses `std.Io` and `std.process.Init`.

```sh
git clone --recurse-submodules https://github.com/grynz-org/GRYNZ.git
cd GRYNZ
zig build -Doptimize=ReleaseFast
zig build run -- --version
```

The installed executable is under `zig-out/bin/` (`grynz.exe` on Windows). Building the CLI does not require installing the website's JavaScript dependencies.

If you already cloned without the website:

```sh
git submodule update --init --recursive
```

## Where GRYNZ is going

These are development directions, not features shipped in the current alpha. The guiding principle is to cooperate with native ecosystem tools while making the entry point consistent.

| Phase | Focus | Concrete milestones |
| --- | --- | --- |
| Foundation | Trustworthy project execution | Preserve child exit status and cancellation; consistent diagnostics; detect manifests such as `Cargo.toml`, `go.mod`, and `package.json`; delegate to native project tools; add explicit overrides and compiler health checks. |
| Workflow | Everyday development | Watch/dev commands with debouncing; delegated test and benchmark commands; profiles; scaffolding; shell completions and better interactive discovery. |
| Monorepo and team workflows | Coordinate larger projects | Explicit task dependencies, cycle detection, bounded parallel execution, and caching based on declared inputs, toolchain identity, and outputs. Evaluate remote cache sharing after local correctness is established. |

WASM language plugins, AI-assisted compiler explanations, and an IDE sidecar are longer-term explorations. They should follow a reliable execution core and demonstrated user demand.

Small distribution size, low startup overhead, and portability across Windows, macOS, and Linux remain design goals. Binary size and startup time need reproducible measurements per target and build configuration; they are not universal guarantees.

## Repository map

```text
src/
  main.zig              CLI entry point and command dispatch
  compiler.zig          Language selection for build/run
  utils.zig             Process execution and argument helpers
  languages/            Language-specific adapters
  projects_detect.zig   Placeholder for future project discovery
  cli.zig               Placeholder for future CLI organization
build.zig               CLI build and run steps
build.zig.zon           Package metadata and Zig version requirement
docs/                   Separate grynz-docs Git submodule
```

### Website repository

The website lives in [grynz-org/grynz-docs](https://github.com/grynz-org/grynz-docs), checked out here as `docs/`. Its [README](docs/README.md) covers development, routes, downloads, and deployment requirements.

Website changes must be committed and pushed in that repository first. Then update and push the `docs` submodule pointer in this repository. This keeps a fresh recursive clone able to resolve the referenced website commit.

## Help shape the project

Useful feedback includes the source file or minimal reproducer, exact GRYNZ command, compiler/runtime versions, operating system, and expected versus actual output. Report bugs and propose workflows through [GitHub issues](https://github.com/grynz-org/GRYNZ/issues).

Keep proposed changes focused, update relevant language documentation, and distinguish existing behavior from planned features. Process correctness and useful project detection are the next foundation to strengthen.

## License

The repository currently carries **CC BY-NC-ND 4.0**, with the restrictions stated in [LICENSE.md](LICENSE.md). Read those terms before using or redistributing the code. This README does not change the license or grant additional permissions.
