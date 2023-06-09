# encoding: utf-8


from ckan import model
from ckan.logic.validators import tag_string_convert


class TestValidators:
    def test_01_tag_string_convert(self):
        def convert(tag_string):
            key = "tag_string"
            data = {key: tag_string}
            errors = []
            context = {"model": model, "session": model.Session}
            tag_string_convert(key, data, errors, context)
            tags = []
            i = 0
            while True:
                tag = data.get(("tags", i, "name"))
                if not tag:
                    break
                tags.append(tag)
                i += 1
            return tags

        assert convert("big, good") == ["big", "good"]
        assert convert("one, several word tag, with-hyphen") == [
            "one",
            "several word tag",
            "with-hyphen",
        ]
        assert convert("") == []
        assert convert("trailing comma,") == ["trailing comma"]
        assert convert("trailing comma space, ") == ["trailing comma space"]
