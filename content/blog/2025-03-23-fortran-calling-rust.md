+++
title = "Fortran calling Rust"
description = "A tour of interfacing Fortran with Rust through a C interface"

[extra]
social_media_image = "blog/fortran-calling-rust/typewriter.png"
+++

{% figure(path="/blog/fortran-calling-rust/typewriter.png",
          alt="Screenshot of an early draft which looks like written on typewriter",
          width=600) %}
Screenshot of an early draft. Maybe writing it on a typewriter would have made
the blog post shorter.  This image is created using the wonderful
[OverType](https://uniqcode.com/typewriter/).
{% end %}


<!-- toc -->


## Why Fortran and Rust?

There are many things I like about modern Fortran (e.g. the simplicity, how
it helps to write modular code, support for pure functions).  What I miss in
modern Fortran are data structures like a hash table (dictionary) or a
vector/list (dynamic array) or a set. These are standard in many other
languages.

{% margin_note_right() %}
Often I feel there is too much focus on potential speed when comparing
languages.

Neither Rust nor Fortran guarantee that your code will be fast.  It is possible
to write slow or unmaintainable code in any language.
{% end %}

What I like about Rust is the tooling, the type safety, the memory safety,
thread safety, and the ecosystem. Rust code can also be really fast and so can
Fortran code.

In one of my projects I needed to add some functionality to a 200k lines
Fortran code.  The thing I needed was possible but not trivial to do in Fortran
(I needed something resembling a priority queue).  I did not want to implement
the basic data structures in Fortran myself or complicate the code by emulating
them using arrays. I chose to write the new part in Rust and call it from
Fortran.

Fortran is very popular in the scientific community (especially in
computational physics and chemistry, in geosciences, and weather forecasting)
and it is here to stay for decades to come. I believe that there will be many
situations where the solution is not to rewrite 1M lines of Fortran code but to
couple these two fine languages. Below I describe how I approach this.


## How?

Rust has excellent interoperability with C. Fortran has excellent
interoperability with C as well (via `iso_c_binding`). This means that a good
medium for Fortran to talk to Rust is via a C interface.  We will see that we
can make the C interface relatively "thin" (perhaps 20 more lines of code to
write?).


## Functions which return a single value

Let's start with a relatively simple example. On the Rust side I will create
few functions that can add numbers and return a single value. On the Fortran
side I will call these functions.

{% margin_note_right() %}
You might prefer to compile the Rust code into `build/` instead of
`rust/target/`. Further below I will show how that can be done.
{% end %}

All examples in this post will use this directory structure:
```txt,hl_lines=4 5 10
.
├── build            <- the build directory
├── CMakeLists.txt
├── example.f90      <- the Fortran code
├── interface.f90    <- here we explain the interface to Fortran
└── rust
    ├── Cargo.lock
    ├── Cargo.toml
    ├── src
    │   └── lib.rs   <- the Rust code
    └── target       <- the default place where Rust compiles to
```

Let's start with the Rust code (`rust/src/lib.rs`).
The first two functions sum two numbers. The third function sums the elements
of an array:
```rust
{{ include_code(path="content/blog/fortran-calling-rust/simple/rust/src/lib.rs") }}
```

{% margin_note_right() %}
Rust does not need to know about the Fortran side. We ask it to create C-compatible
interfaces with the `pub extern "C"` and `#[unsafe(no_mangle)]` attributes.
{% end %}

We should also inspect the `Cargo.toml` file. The highlighted line is important to
get a C-compatible dynamic library:
```toml,hl_lines=7
{{ include_code(path="content/blog/fortran-calling-rust/simple/rust/Cargo.toml") }}
```

{% margin_note_left() %}
Fortran does not know that it will be calling Rust. It thinks it is talking to
C.

I am not sure about the highlighted line. Maybe `c_size_t` would be more
correct here but then I would have to use `interger(8)` on the Fortran side.
{% end %}

Now let us look at the Fortran interface file (`interface.f90`):
```f90,hl_lines=25
{{ include_code(path="content/blog/fortran-calling-rust/simple/interface.f90") }}
```

Here is `example.f90` which uses the Rust code via the interface:
```f90
{{ include_code(path="content/blog/fortran-calling-rust/simple/example.f90") }}
```

Finally, the `CMakeLists.txt` file:
```cmake
{{ include_code(path="content/blog/fortran-calling-rust/simple/CMakeLists.txt") }}
```

I compile the Rust part separately:
```bash
$ cd rust
$ cargo build --release
$ cd ..
```

{% margin_note_right() %}
Yes, there is a more portable way to configure and build a CMake project but my
muscle memory is trained to build this way.
{% end %}

This is how I compile the Fortran part:
```bash
$ mkdir build
$ cd build
$ cmake ..
$ make
```

This is the output I got. Seems to be working:
```txt
sum of two integers:           5
sum of two doubles:   5.0000000000000000
sum of 1D array:          15
sum of 2D array:           6
```


## Do we need to worry about the C naming convention?

We don't have to worry about the C naming convention and [name
mangling](https://en.wikipedia.org/wiki/Name_mangling).  The `extern "C"`
attribute creates a C-compatible interface. The `no_mangle` attribute tells
Rust not to mangle (modify) the name of the function and make it findable by
the linker under this name (`sum_integer_array`):
```rust
#[unsafe(no_mangle)]
pub unsafe extern "C" fn sum_integer_array(data: *const i32, size: usize) -> i32 {
    // ...
}
```

{% margin_note_right() %}
In this case both languages use the same name. It is possible to bind a Fortran
interface to a C function (exported from Rust) with a different name.
{% end %}

On the Fortran side we used `bind(c)` to bind this to a C function with the same
name:
```f90
function sum_integer_array(data, size) result(output) bind(c)
    ! ...
```

How about the `unsafe` keyword? Is my code unsafe now? This just means
that we are leaving the jurisdiction of the Rust borrow checker and it is up to us
to use this function in a responsible way.


## Should we not compile the Rust library as part of CMake?

It is possible to instruct CMake to compile the Rust library as part of the
build process and do everything in one go.

I prefer to do this separately. It reduces the complexity of `CMakeLists.txt`
and it gives me the flexibility to iterate on the Rust code without having to
recompile/relink the whole project every time I change a tiny thing on the Rust
side since the Rust code is dynamically linked.


## Working with arrays

Here we will take it one step further and modify arrays on the Rust side.

{% margin_note_right() %}
The allocation and deallocation of memory is managed by Fortran. It would
be possible to allocate Rust-side and return a pointer to Fortran but I find
it easier to let Fortran manage the memory for arrays used in Fortran.
{% end %}

This is the Rust code (`rust/src/lib.rs`):
```rust
{{ include_code(path="content/blog/fortran-calling-rust/arrays/rust/src/lib.rs") }}
```

{% margin_note_right() %}
No surprises here.
{% end %}

This is the interface (`interface.f90`):
```f90
{{ include_code(path="content/blog/fortran-calling-rust/arrays/interface.f90") }}
```

{% margin_note_right() %}
The two interesting calls are highlighted.
{% end %}

Finally, the Fortran code (`example.f90`):
```f90,hl_lines=18 35
{{ include_code(path="content/blog/fortran-calling-rust/arrays/example.f90") }}
```

To get the same order of elements in the 2D array on the Rust and Fortran side,
I had to reorder the elements in the Rust code:
```txt
sum of 1D array:          15
after modification:          30

[src/lib.rs:55:5] result = [
    [
        1.0,
        2.0,
        3.0,
    ],
    [
        4.0,
        5.0,
        6.0,
    ],
]
```


## Maintaining a context on the Rust side

{% margin_note_right() %}
In my real-world case I wanted to initialize a priority queue once and then
query it a million times.
{% end %}

In the next example I wanted to initialize/allocate some data in Rust once,
then query the code many times, and finalize/deallocate at the end:
```f90
{{ include_code(path="content/blog/fortran-calling-rust/context/example.f90") }}
```

This is the interface (`interface.f90`):
```f90
{{ include_code(path="content/blog/fortran-calling-rust/context/interface.f90") }}
```

On the Rust side I achieved this by using [once_cell
crate](https://crates.io/crates/once_cell) which will hold the context/state
across the queries:
```toml,hl_lines=10
{{ include_code(path="content/blog/fortran-calling-rust/context/rust/Cargo.toml") }}
```

{% margin_note_right() %}
The `struct State` holds the context/state and the code makes sure that I can
only have one instance of it at a time.

Later I will show examples where we can maintain multiple contexts.
{% end %}

This is the Rust code (`rust/src/lib.rs`):
```rust
{{ include_code(path="content/blog/fortran-calling-rust/context/rust/src/lib.rs") }}
```


## Example: Using Rust's HashMap in Fortran

In the next example I want to be able to allocate and hold some data structures
on the Rust side, and then query and modify them from Fortran. And I want to be
able to have more than one instance of these data structures.

{% margin_note_left() %}
HashMap is one of those data structures that I miss most in Fortran.
{% end %}

{% margin_note_right() %}
In the Rust code example I was lazy writing the actual safety notices.
{% end %}

The example data structure will be a HashMap but we can imagine something more
involved (`rust/src/lib.rs`):
```rust
{{ include_code(path="content/blog/fortran-calling-rust/hashmap/rust/src/lib.rs") }}
```

This is the interface (`interface.f90`):
```f90
{{ include_code(path="content/blog/fortran-calling-rust/hashmap/interface.f90") }}
```

And here the example Fortran code (`example.f90`):
```f90
{{ include_code(path="content/blog/fortran-calling-rust/hashmap/example.f90") }}
```


## Making the HashMap interface more ergonomic

Having the `c_ptr` exposed on the Fortran side looks a bit awkward. Also notice
that we are passing the context as an argument to every function.

{% margin_note_right() %}
In other languages the `%` symbol would often be a dot.
{% end %}

We can try to make this more ergonomic by hiding the `c_ptr` and make the hash table
behave more like we interact with such data structures in Rust:
```f90
{{ include_code(path="content/blog/fortran-calling-rust/hashmap-as-type/example.f90") }}
```

To implement this **we don't need to change anything on the Rust side**.  The
necessary changes are highlighted in the interface file (`interface.f90`):
```f90,hl_lines=7-14 41-73
{{ include_code(path="content/blog/fortran-calling-rust/hashmap-as-type/interface.f90") }}
```

Nice! And of course many more improvements are possible but now we have the
tools. **Now go and have fun using Rust from Fortran! The world is your oyster.**


## Checking for memory leaks

I used [Valgrind](https://valgrind.org/) to check whether any of the solutions
leak memory:
```bash
$ valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./example
```


## Maybe you prefer the Rust library in the build dir?

Instead of this (writes to `rust/target/`):
```bash
$ cd rust
$ cargo build --release
```

You can also do this (writes to `build/target/`):
```bash
$ cd build
$ cargo build --release \
              --manifest-path ../src/rust/Cargo.toml \
              --target-dir $(pwd)/target
```


## Versions used to test the code examples

- Rust 1.85.0
- CMake 3.30.5
- GNU Fortran (GCC) 13.3.0
