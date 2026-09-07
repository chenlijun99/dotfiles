from __future__ import annotations

import unittest

import tomllib
from mutable_config import BEGIN_MARKER, END_MARKER, ConfigError, merge_config


class MergeConfigTest(unittest.TestCase):
    def test_static_settings_win_and_runtime_tables_survive(self) -> None:
        existing = """
model = "runtime-model"

[features]
hooks = false

[projects."/workspace"]
trust_level = "trusted"
"""
        static = """
model_provider = "portkey"

[features]
hooks = true
"""

        parsed = tomllib.loads(merge_config(existing, static))

        self.assertEqual(parsed["model"], "runtime-model")
        self.assertEqual(parsed["model_provider"], "portkey")
        self.assertTrue(parsed["features"]["hooks"])
        self.assertEqual(parsed["projects"]["/workspace"]["trust_level"], "trusted")

    def test_mixed_scope_nono_block_is_preserved_and_sandwiched(self) -> None:
        block = f"""{BEGIN_MARKER}
developer_instructions = "owned by nono"
model = "runtime-model"

[marketplaces.nolabs-ai]
source_type = "local"

[plugins."nono@nolabs-ai"]
enabled = true

[projects."/workspace"]
trust_level = "trusted"
{END_MARKER}"""
        existing = f"""model_provider = "old-provider"

[tui]
status_line_use_colors = false

{block}
"""
        static = """model_provider = "portkey"

[features]
hooks = true

[tui]
status_line_use_colors = true
"""

        rendered = merge_config(existing, static)
        parsed = tomllib.loads(rendered)

        self.assertIn(block, rendered)
        self.assertLess(
            rendered.index('model_provider = "portkey"'), rendered.index(block)
        )
        self.assertLess(rendered.index(block), rendered.index("[features]"))
        self.assertEqual(parsed["developer_instructions"], "owned by nono")
        self.assertEqual(parsed["model"], "runtime-model")
        self.assertEqual(parsed["model_provider"], "portkey")
        self.assertTrue(parsed["features"]["hooks"])
        self.assertTrue(parsed["tui"]["status_line_use_colors"])
        self.assertEqual(parsed["projects"]["/workspace"]["trust_level"], "trusted")

    def test_collision_with_managed_block_fails(self) -> None:
        existing = f"""developer_instructions = "outside"

{BEGIN_MARKER}
developer_instructions = "inside"

[plugins."nono@nolabs-ai"]
enabled = true
{END_MARKER}
"""

        with self.assertRaisesRegex(ConfigError, "merged config"):
            merge_config(existing, "")

    def test_incomplete_managed_block_fails(self) -> None:
        with self.assertRaisesRegex(ConfigError, "complete nono-managed block"):
            merge_config(f'{BEGIN_MARKER}\nmodel = "gpt"\n', "")


if __name__ == "__main__":
    unittest.main()
