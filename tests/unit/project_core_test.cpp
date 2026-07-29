#include "project_name/project_core.hpp"

#include <gtest/gtest.h>

TEST(ProjectCore, ProvidesGreeting) {
  EXPECT_EQ(project_name::greeting(), "project_name is ready");
}
