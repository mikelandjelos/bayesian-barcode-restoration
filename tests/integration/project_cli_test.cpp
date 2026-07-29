#include <gtest/gtest.h>

#include "project_name/project_core.hpp"

TEST(ProjectCliIntegration, CoreLibraryIsConsumable) {
  EXPECT_FALSE(project_name::greeting().empty());
}
