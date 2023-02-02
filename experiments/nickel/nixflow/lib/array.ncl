{
	foldr
		| doc m%"
			foldr f a bs =
				 foldl (\g b x -> g (f b x)) id bs a
			"%
		= fun f a bs =>
		array.foldl (fun g b x => g (f b x)) function.id bs a,

	zip 
		| doc m%"
			FIXME zip xs ys = foldr f (const []) xs ys
			where
				f x r []     = []
				f x r (y:ys) = (x,y) : r ys
		  "%
		= fun xs ys =>
			let f = fun x r ys =>
			if array.length ys == 0 then []
			else array.cons [x, (array.head ys)] r (array.tail ys)
			in foldr f (function.const []) xs ys,

}


