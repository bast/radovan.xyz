#[unsafe(no_mangle)]
pub extern "C" fn sum_two_integers(a: i32, b: i32) -> i32 {
    a + b
}

#[unsafe(no_mangle)]
pub extern "C" fn sum_two_doubles(a: f64, b: f64) -> f64 {
    a + b
}

/// # Safety
///
/// Function assumes that the input data is a valid pointer to an array and that the
/// array size matches the `size` parameter.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn sum_integer_array(data: *const i32, size: usize) -> i32 {
    if data.is_null() {
        return 0;
    }

    let slice = unsafe { std::slice::from_raw_parts(data, size) };

    slice.iter().sum()
}
