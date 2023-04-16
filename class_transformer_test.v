module validator

struct BasicStruct {
	str string [req; min_length:3; max_length: 15]
	number int [req; min:3; max: 100]
	b bool [req]
}

struct DefaultsStruct {
	str string = 'some string' 
	number int = 35
}

fn te_st_basic_struct() {
	data := transform_and_validate[BasicStruct]({
		'str':'string'
		'number': '42'
		'b': 'true'
	})
	assert (data is BasicStruct)
	if data is BasicStruct{
		assert data.str == 'string'
		assert data.number == 42, 'should load the default of the struct'
		assert data.b == true
	}
}

fn te_st_basic_struct_without_data() {
	data := transform_and_validate[BasicStruct]({})
	assert data is map[string][]IError 
	if data is map[string][]IError {
		assert 'str' in data
		assert 'number' in data
		str := data['str'][0]
		assert str is FieldError
		if str is FieldError{
			assert str.int_code == FieldErrorEnum.required
		}
		number := data['number'][0]
		assert number is FieldError
		if number is FieldError{
			assert number.int_code == FieldErrorEnum.required
		}
	}
}

fn test_min_length(){
	data := transform_and_validate[BasicStruct]({
		'str': ''
		'number': '10'
	})
	assert data is map[string][]IError 
	if data is map[string][]IError{
		str := data['str'][0]
		if str is FieldError{
			assert str.int_code == .min_length
		} else {
			assert false, 'data is not FieldError'
		}
	} else {
		assert false, "data is not an error"
	}
}

fn test_max_length(){
	data := transform_and_validate[BasicStruct]({
		'str': '1234567890123456'
		'number': '11'
	})
	assert data is map[string][]IError 
	if data is map[string][]IError{
		str := data['str'][0]
		if str is FieldError{
			assert str.int_code == .max_length
		} else {
			assert false, 'data is not FieldError'
		}
	} else {
		assert false, "data is not an error"
	}
}


fn test_min_int(){
	data := transform_and_validate[BasicStruct]({
		'str': '12345'
		'number': '0'
	})
	assert data is map[string][]IError 
	if data is map[string][]IError{
		number := data['number'][0]
		if number is FieldError{
			assert number.int_code == .min
		} else {
			assert false, 'data is not FieldError'
		}
	} else {
		assert false, "data is not an error"
	}
}

fn test_max_int(){
	data := transform_and_validate[BasicStruct]({
		'str': '12345'
		'number': '101'
	})
	assert data is map[string][]IError 
	if data is map[string][]IError{
		number := data['number'][0]
		if number is FieldError{
			assert number.int_code == .max
		} else {
			assert false, 'data is not FieldError'
		}
	} else {
		assert false, "data is not an error"
	}
}