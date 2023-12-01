module validator

struct BasicStruct {
	str    string @[max_length: 15; min_length: 3; req]
	number int    @[max: 100; min: 3; req]
	b      bool   @[req]
}

struct DefaultsStruct {
	str    string = 'some string'
	number int    = 35
}

fn test_basic_struct() {
	data_with_errors := transform_and_validate[BasicStruct]({
		'str':    'string'
		'number': '42'
		'b':      'true'
	})
	assert data_with_errors.has_errors() == false
	data := data_with_errors.value
	assert data.str == 'string'
	assert data.number == 42, 'should load the default of the struct'
	assert data.b == true
}

fn test_basic_struct_without_data() {
	data_with_errors := transform_and_validate[BasicStruct]({})
	assert data_with_errors.has_errors()

	assert 'str' in data_with_errors.errors
	assert 'number' in data_with_errors.errors
	str := data_with_errors.errors['str'][0]
	assert str is FieldError
	if str is FieldError {
		assert str.int_code == FieldErrorEnum.required
	}
	number := data_with_errors.errors['number'][0]
	assert number is FieldError
	if number is FieldError {
		assert number.int_code == FieldErrorEnum.required
	}
}

fn test_min_length() {
	data_with_errors := transform_and_validate[BasicStruct]({
		'str':    ''
		'number': '10'
	})
	assert data_with_errors.has_errors()
	str := data_with_errors.errors['str'][0]
	if str is FieldError {
		assert str.int_code == .min_length
	} else {
		assert false, 'data is not FieldError'
	}
}

fn test_max_length() {
	data_with_errors := transform_and_validate[BasicStruct]({
		'str':    '1234567890123456'
		'number': '11'
	})

	assert data_with_errors.errors.len > 0
	str := data_with_errors.errors['str'][0]
	if str is FieldError {
		assert str.int_code == .max_length
	} else {
		assert false, 'data is not FieldError'
	}
}

fn test_min_int() {
	data_with_errors := transform_and_validate[BasicStruct]({
		'str':    '12345'
		'number': '0'
	})
	assert data_with_errors.errors.len > 0

	number := data_with_errors.errors['number'][0]
	if number is FieldError {
		assert number.int_code == .min
	} else {
		assert false, 'data is not FieldError'
	}
}

fn test_max_int() {
	data_with_errors := transform_and_validate[BasicStruct]({
		'str':    '12345'
		'number': '101'
	})
	assert data_with_errors.has_errors()
	number := data_with_errors.errors['number'][0]
	if number is FieldError {
		assert number.int_code == .max
	} else {
		assert false, 'data is not FieldError'
	}
}
