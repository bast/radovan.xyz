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

/// # Safety
///
/// Function assumes that the input data is a valid pointer to an array and that the
/// array size matches the `size` parameter.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn modify_array(data: *mut i32, size: usize) {
    if data.is_null() {
        return;
    }

    let slice = unsafe { std::slice::from_raw_parts_mut(data, size) };

    for element in slice {
        *element *= 2;
    }
}

/// # Safety
///
/// Function assumes that the input data is a valid pointer to an array and that the
/// array size matches the `size` parameter.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn check_array_order(data: *const f64, size: usize) {
    if data.is_null() {
        return;
    }

    let slice = unsafe { std::slice::from_raw_parts(data, size) };

    let n = size / 3;
    let mut result = vec![[0.0; 3]; n];

    // copy values from fortran-order into row-major representation
    for i in 0..n {
        result[i][0] = slice[i];
        result[i][1] = slice[i + n];
        result[i][2] = slice[i + 2 * n];
    }

    dbg!(result);
}
