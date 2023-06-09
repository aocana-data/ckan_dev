# encoding: utf-8

from ckan import model
import ckan.lib.search as search
import pytest
from ckan.tests.legacy import CreateTestData, setup_test_search_index
from ckan.tests.legacy.lib import check_search_results
import json


class TestSearchOverallWithSynchronousIndexing(object):
    """Repeat test from test_package_search with synchronous indexing
    """

    @pytest.fixture(autouse=True)
    def setup_class(self, clean_db, clean_index):
        # Force a garbage collection to trigger issue #695
        import gc

        gc.collect()

        CreateTestData.create()

        new_pkg_dict = {
            "name": "council-owned-litter-bins",
            "notes": "Location of Council owned litter bins within Borough.",
            "resources": [
                {
                    "description": "Resource locator",
                    "format": "Unverified",
                    "url": "http://www.barrowbc.gov.uk",
                }
            ],
            "tags": ["Utility and governmental services"],
            "title": "Council Owned Litter Bins",
            "extras": {
                "INSPIRE": "True",
                "bbox-east-long": "-3.12442",
                "bbox-north-lat": "54.218407",
                "bbox-south-lat": "54.039634",
                "bbox-west-long": "-3.32485",
                "constraint": "conditions unknown; (e) intellectual property rights;",
                "dataset-reference-date": json.dumps(
                    [
                        {"type": "creation", "value": "2008-10-10"},
                        {"type": "revision", "value": "2009-10-08"},
                    ]
                ),
                "guid": "00a743bf-cca4-4c19-a8e5-e64f7edbcadd",
                "metadata-date": "2009-10-16",
                "metadata-language": "eng",
                "published_by": 0,
                "resource-type": "dataset",
                "spatial-reference-system": "test-spatial",
                "temporal_coverage-from": "1977-03-10T11:45:30",
                "temporal_coverage-to": "2005-01-15T09:10:00",
            },
        }

        CreateTestData.create_arbitrary(new_pkg_dict)

    def _remove_package(self, name=None):
        package = model.Package.by_name(name or "council-owned-litter-bins")
        if package:
            package.purge()
            model.repo.commit_and_remove()

    def test_02_add_package_from_dict(self):
        check_search_results("", 3)
        check_search_results("spatial", 1, ["council-owned-litter-bins"])

    def test_03_update_package_from_dict(self):
        package = model.Package.by_name("council-owned-litter-bins")

        # update package
        package.name = u"new_name"
        extra = model.PackageExtra(key="published_by", value="barrow")
        package._extras[extra.key] = extra
        model.repo.commit_and_remove()

        check_search_results("", 3)
        check_search_results("barrow", 1, ["new_name"])

        # update package again
        package = model.Package.by_name("new_name")
        package.name = u"council-owned-litter-bins"
        model.repo.commit_and_remove()

        check_search_results("", 3)
        check_search_results("spatial", 1, ["council-owned-litter-bins"])

    def test_04_delete_package_from_dict(self):
        package = model.Package.by_name("council-owned-litter-bins")
        assert package
        check_search_results("", 3)

        # delete it
        package.delete()
        model.repo.commit_and_remove()

        check_search_results("", 2)
