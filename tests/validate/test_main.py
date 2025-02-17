from frictionless import Resource, Field, validate, describe


# Table


def test_validate():
    report = validate("data/table.csv")
    assert report.valid


def test_validate_invalid():
    report = validate("data/invalid.csv")
    assert report.flatten(["rowPosition", "fieldPosition", "code"]) == [
        [None, 3, "blank-label"],
        [None, 4, "duplicate-label"],
        [2, 3, "missing-cell"],
        [2, 4, "missing-cell"],
        [3, 3, "missing-cell"],
        [3, 4, "missing-cell"],
        [4, None, "blank-row"],
        [5, 5, "extra-cell"],
    ]


def test_validate_from_resource_instance():
    resource = Resource("data/table.csv")
    report = validate(resource)
    assert report.valid


# Issues


def test_validate_multiple_files_issue_850():
    report = validate("data/package/*.csv")
    assert report.stats["tasks"] == 2


def test_validate_less_actual_fields_with_required_constraint_issue_950():
    schema = describe("data/table.csv", type="schema")
    schema.add_field(Field(name="bad", constraints={"required": True}))
    report = validate("data/table.csv", schema=schema)
    assert report.flatten(["rowPosition", "fieldPosition", "code"]) == [
        [None, 3, "missing-label"],
        [2, 3, "missing-cell"],
        [3, 3, "missing-cell"],
    ]
