module 0x1337::m0veCon {

    use std::vector;

    // Bigram and Words as constant arrays
    const BIGRAMS: vector<u8> = b"scoligainelespniitrocomolothllchewrtteeaalsadofoaysteessasfiadidctatepenrinoacofhaveiotrshheimicontiiliramemsumiulecreedsosiopdepaieusiaouhondgetteslyowtonsarwetyortaryyoinuntusencanhingdabeiscameotrsoselceliermaviwiagraeiivlatspromdipewaoopletntnaurpoutab";
    const WORDS: vector<vector<u8>> = vector[b"could", b"message", b"international", b"read", b"family", b"event", b"store", b"detail", b"system", b"version", b"last", b"national", b"need", b"link", b"travel", b"member", b"each", b"click", b"access", b"over", b"general", b"black", b"south", b"address", b"program", b"high", b"that", b"shopping", b"said", b"download", b"forum", b"another", b"number", b"only", b"comment", b"main", b"subject", b"data", b"site", b"following", b"hotel", b"year", b"center", b"view", b"must", b"well", b"product", b"computer", b"internet", b"software", b"back", b"there", b"about", b"just", b"phone", b"price", b"next", b"like", b"some", b"between", b"part", b"management", b"county", b"within", b"will", b"still", b"text", b"development", b"those", b"small", b"january", b"information", b"such", b"location", b"water", b"result", b"child", b"work", b"related", b"city", b"want", b"before", b"security", b"size", b"education", b"very", b"than", b"world", b"women", b"since", b"project", b"even", b"health", b"support", b"open", b"order", b"government", b"show", b"case", b"info", b"then", b"total", b"ebay", b"company", b"from", b"rating", b"house", b"first", b"type", b"more", b"down", b"which", b"real", b"please", b"where", b"group", b"level", b"days", b"have", b"long", b"north", b"digital", b"profile", b"directory", b"using", b"during", b"personal", b"white", b"business", b"report", b"them", b"most", b"area", b"home", b"item", b"video", b"care", b"many", b"privacy", b"local", b"people", b"account", b"make", b"free", b"including", b"shipping", b"service", b"history", b"contact", b"design", b"control", b"would", b"media", b"mail", b"sign", b"does", b"your", b"available", b"resource", b"through", b"review", b"network", b"send", b"into", b"music", b"sport", b"life", b"here", b"guide", b"file", b"user", b"post", b"technology", b"university", b"place", b"great", b"reserved", b"full", b"date", b"board", b"office", b"list", b"what", b"both", b"also", b"same", b"american", b"form", b"game", b"based", b"code", b"today", b"index", b"being", b"united", b"when", b"help", b"section", b"state", b"name", b"policy", b"current", b"return", b"think", b"know", b"much", b"found", b"posted", b"under", b"special", b"page", b"this", b"news", b"student", b"good", b"used", b"book", b"online", b"right", b"public", b"rate", b"community", b"three", b"with", b"term", b"line", b"been", b"love", b"time", b"while", b"their", b"power", b"without", b"website", b"best", b"should", b"search", b"copyright", b"research", b"other", b"class", b"previous", b"these", b"they", b"change", b"shop", b"find", b"because", b"picture", b"after", b"school", b"were", b"made", b"take", b"check", b"email"];

    fun sub_range(v: &vector<u8>, start: u64, end: u64): vector<u8> {
        let res: vector<u8> = vector::empty();
        let i = start;
        while (i < end) {
            vector::push_back(&mut res, *vector::borrow(v, i));
            i = i + 1;
        };
        res
    }

    fun vector_equals(v1: vector<u8>, v2: vector<u8>): bool {
        if (vector::length(&v1) != vector::length(&v2)) {
            return false
        };
        let i = 0;
        while (i < vector::length(&v1)) {
            if (*vector::borrow(&v1, i) != *vector::borrow(&v2, i)) {
                return false
            };
            i = i + 1;
        };
        true
    }

    public fun compress(input: vector<u8>): vector<u8> {
        let dst: vector<u8> = vector::empty(); // Compressed data output
        let verblen: u8 = 0;

        let flag: bool;
        let s: vector<u8> = copy input;
        let i: u64;

        while (!vector::is_empty(&s)) {
            flag = false;

            if (vector::length(&s) >= 4) {
                i = 0;
                while (i < vector::length(&WORDS)) {
                    let w = vector::borrow(&WORDS, i);
                    let wordlen = vector::length(w);
                    let space = if (*vector::borrow(&s, 0) == 32) 1 else 0;

                    if (vector::length(&s) >= wordlen + space) {
                        let match_word = sub_range(&s, space as u64, (wordlen + space) as u64);

                        if (vector_equals(match_word, *w)) {
                            flag = true;
                            break
                        };
                    };
                    i = i + 1;
                };

                if (flag) {
                    if (*vector::borrow(&s, 0) == 32) {
                        vector::push_back(&mut dst, 8); // Space + word escape
                        vector::push_back(&mut dst, i as u8);
                        s = sub_range(&s, 1, vector::length(&s));
                    } else if (vector::length(&s) > vector::length(vector::borrow(&WORDS, i)) && *vector::borrow(&s, vector::length(vector::borrow(&WORDS, i))) == 32) {
                        vector::push_back(&mut dst, 7); // Word + space escape
                        vector::push_back(&mut dst, i as u8);
                        s = sub_range(&s, 1, vector::length(&s));
                    } else {
                        vector::push_back(&mut dst, 6); // Just word escape
                        vector::push_back(&mut dst, i as u8);
                    };
                    s = sub_range(&s, vector::length(vector::borrow(&WORDS, i)), vector::length(&s));
                    verblen = 0;
                    continue
                };
            };

            // Try to find a matching bigram
            if (vector::length(&s) >= 2) {
                i = 0;
                while (i < vector::length(&BIGRAMS)) {
                    if (vector_equals(sub_range(&s, 0, 2), sub_range(&BIGRAMS, i, i + 2))) {
                        flag = true;
                        break
                    };
                    i = i + 2;
                };
                if (flag) {
                    vector::push_back(&mut dst, (1 << 7 | (i / 2) as u8) as u8);
                    s = sub_range(&s, 2, vector::length(&s));
                    verblen = 0;
                    continue
                };
            };

            // Emit the byte as it is
            let byte = vector::borrow(&s, 0);
            if (!(0 < *byte && *byte < 9) && *byte < 128) {
                vector::push_back(&mut dst, *byte);
                s = sub_range(&s, 1, vector::length(&s));
                verblen = 0;
                continue
            };

            // Handle verbatim sequence
            verblen = verblen + 1;
            if (verblen == 1) {
                vector::push_back(&mut dst, verblen);
                vector::push_back(&mut dst, *byte);
            } else {
                vector::push_back(&mut dst, *byte);
                let verblen_idx = vector::length(&dst) - (verblen + 1 as u64);
                *vector::borrow_mut(&mut dst, verblen_idx) = verblen;
                if (verblen == 5) {
                    verblen = 0;
                };
            };
            s = sub_range(&s, 1, vector::length(&s));
        };

        dst
    }

    #[test]
    fun main() {
        use std::debug;

        let input: vector<u8> = b"FLAG";
        let compressed: vector<u8> = compress(input);
        debug::print(&compressed);
    }
}
