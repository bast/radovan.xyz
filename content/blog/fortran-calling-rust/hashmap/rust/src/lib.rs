use std::collections::HashMap;

#[unsafe(no_mangle)]
pub extern "C" fn create_map() -> *mut HashMap<i32, i32> {
    Box::into_raw(Box::new(HashMap::new()))
}

/// # Safety
///
/// Safety notice needed here.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn insert_into_map(map_ptr: *mut HashMap<i32, i32>, key: i32, value: i32) {
    if map_ptr.is_null() {
        return;
    }
    let map = unsafe { &mut *map_ptr };
    map.insert(key, value);
}

/// # Safety
///
/// Safety notice needed here.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn get_from_map(map_ptr: *mut HashMap<i32, i32>, key: i32) -> i32 {
    if map_ptr.is_null() {
        return -1; // return -1 if the map is null
    }
    let map = unsafe { &mut *map_ptr };
    *map.get(&key).unwrap_or(&-1) // return -1 if key is not found
}

/// # Safety
///
/// Safety notice needed here.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn destroy_map(map_ptr: *mut HashMap<i32, i32>) {
    if map_ptr.is_null() {
        return;
    }
    unsafe {
        drop(Box::from_raw(map_ptr));
    }
}
