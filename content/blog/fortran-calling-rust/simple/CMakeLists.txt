cmake_minimum_required(VERSION 3.10)

project("example" LANGUAGES Fortran)

add_executable(example "example.f90")

target_sources(
  example
  PRIVATE
    "interface.f90"
  )

target_link_libraries(
  example
  PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/rust/target/release/librust.so"
  )
