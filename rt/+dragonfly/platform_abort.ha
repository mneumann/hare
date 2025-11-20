// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

fn strvec(s: str) iovec = {
	return iovec {
		iov_base = *(&s: **opaque),
		iov_len = len(s),
	};
};
export fn debug_u64(num: u64) void = {
	let numbuf: [U64_BUFSZ]u8 = [0...];
	const iov = [
		strvec(u64tos(numbuf, num)),
		strvec("\n"),
	];
	_ = writev(STDERR_FILENO, &iov, len(iov): int);

};

export fn debug_raw(ptr: *opaque, sz: size) void = {
	const iov = [
		iovec {
			iov_base = ptr,
			iov_len = sz,
		},
		strvec("\n"),
	];
	_ = writev(STDERR_FILENO, &iov, len(iov): int);
};

export fn debug(msg: str) void = {
	const iov = [
		strvec(msg),
		strvec("\n"),
	];
	_ = writev(STDERR_FILENO, &iov, len(iov): int);
};

fn platform_abort(path: *str, line: u64, col: u64, msg: str) never = {
	let linebuf: [U64_BUFSZ]u8 = [0...];
	let colbuf: [U64_BUFSZ]u8 = [0...];

	const iov = [
		strvec("Abort: "),
		strvec(*path),
		strvec(":"),
		strvec(u64tos(linebuf, line)),
		strvec(":"),
		strvec(u64tos(colbuf, col)),
		strvec(": "),
		strvec(msg),
		strvec("\n"),
	];
	_ = writev(STDERR_FILENO, &iov, len(iov): int);

	for (true) {
		_ = kill(getpid(), SIGABRT);
	};
};
