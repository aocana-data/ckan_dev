# encoding: utf-8


from ckan.tests.legacy.functional.api.base import (
    ApiTestCase,
    ControllerTestCase,
    Api3TestCase,
)
from ckan.tests.helpers import body_contains


class ApiTestCase(ApiTestCase, ControllerTestCase):
    def test_get_api(self, app):
        offset = self.offset("")
        res = app.get(offset, status=200)
        self.assert_version_data(res)

    def assert_version_data(self, res):
        data = self.data_from_res(res)
        assert "version" in data, data
        expected_version = self.get_expected_api_version()
        assert data["version"] == expected_version


class TestApi3(Api3TestCase, ApiTestCase):
    def test_readonly_is_get_able_with_normal_url_params(self, app):
        """Test that a read-only action is GET-able

        Picks an action within `get.py` and checks that it works if it's
        invoked with a http GET request.  The action's data_dict is
        populated from the url parameters.
        """
        offset = self.offset("/action/package_search")
        params = {"q": "russian"}
        res = app.get(offset, params=params, status=200)

    def test_sideeffect_action_is_not_get_able(self, app):
        """Test that a non-readonly action is not GET-able.

        Picks an action outside of `get.py`, and checks that it 400s if an
        attempt to invoke with a http GET request is made.
        """
        offset = self.offset("/action/package_create")
        data_dict = {"type": "dataset", "name": "a-name"}
        res = app.get(
            offset, json=data_dict, status=400
        )
        assert body_contains(
            res,
            "Bad request - JSON Error: Invalid request."
            " Please use POST method for your request"
        )
