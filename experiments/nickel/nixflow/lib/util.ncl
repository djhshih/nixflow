{
	zip : forall a. Array a -> Array a -> Array (Array a)
		| doc m%"
			zip xs ys = foldr f (const []) xs ys
			where
				f x r []     = []
				f x r (y:ys) = (x,y) : r ys
		  "%
		= fun xs ys =>
			let f = fun x r ys =>
			if array.length ys == 0 then []
			else array.cons [x, array.head ys] (r (array.tail ys))
			in array.fold f (function.const []) xs ys,

	fst : forall a. Array a -> a
		= fun xs => array.elem_at 0 xs,

	snd : forall a. Array a -> a
		= fun xs => array.elem_at 1 xs,

	replace_all : Array Str -> Array Str -> Str -> Str
		| doc m%"
			Replace in `s` all `xs` with corresponding element from `ys`
			"%
		= fun xs ys s =>
		let pairs = zip xs ys in
		let replacep = (fun s p => string.replace (fst p) (snd p) s) in
		array.foldl replacep s pairs,
}
