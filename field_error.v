module validator

struct FieldError {
	int_code    FieldErrorEnum
	int_message string
}

fn (err FieldError) code() int {
	return int(err.int_code)
}

fn (err FieldError) msg() string {
	return err.int_message
}

[inline]
fn error(code FieldErrorEnum, msg string) FieldError {
	return FieldError{
		int_code: code
		int_message: msg
	}
}