# make sure we have the correct interaction mark for tests
options(parameters_interaction = "*")

data(iris)
m1 <- lm(Sepal.Length ~ Species, data = iris)
m2 <- lm(Sepal.Length ~ Species * Petal.Length, data = iris)
counts <- c(18, 17, 15, 20, 10, 20, 25, 13, 12)
outcome <- gl(3, 1, 9)
treatment <- gl(3, 3)
m3 <- glm(counts ~ outcome + treatment, family = poisson())

x <- compare_parameters(m1, m2, m3)
test_that("compare_parameters, default", {
  expect_identical(
    colnames(x),
    c(
      "Parameter", "Component", "Effects", "Coefficient.m1", "SE.m1", "CI.m1",
      "CI_low.m1", "CI_high.m1", "t.m1", "df_error.m1", "p.m1", "Coefficient.m2",
      "SE.m2", "CI.m2", "CI_low.m2", "CI_high.m2", "t.m2", "df_error.m2",
      "p.m2", "Log-Mean.m3", "SE.m3", "CI.m3", "CI_low.m3", "CI_high.m3",
      "z.m3", "df_error.m3", "p.m3"
    )
  )
  out <- capture.output(x)
  expect_length(out, 14)
  out <- format(x, select = "ci")
  expect_identical(colnames(out), c("Parameter", "m1", "m2", "m3"))
  expect_identical(
    out$Parameter,
    c(
      "(Intercept)", "Species (versicolor)", "Species (virginica)",
      "Petal Length", "Species (versicolor) * Petal Length",
      "Species (virginica) * Petal Length", "outcome (2)", "outcome (3)",
      "treatment (2)", "treatment (3)", NA, "Observations"
    )
  )
})


x <- compare_parameters(m1, m2, m3, select = "se_p2")
test_that("compare_parameters, se_p2", {
  expect_identical(
    colnames(x),
    c(
      "Parameter", "Component", "Effects", "Coefficient.m1", "SE.m1", "CI.m1",
      "CI_low.m1", "CI_high.m1", "t.m1", "df_error.m1", "p.m1", "Coefficient.m2",
      "SE.m2", "CI.m2", "CI_low.m2", "CI_high.m2", "t.m2", "df_error.m2",
      "p.m2", "Log-Mean.m3", "SE.m3", "CI.m3", "CI_low.m3", "CI_high.m3",
      "z.m3", "df_error.m3", "p.m3"
    )
  )
  out <- capture.output(x)
  expect_length(out, 14)
  out <- format(x, select = "se_p2")
  expect_identical(
    colnames(out),
    c(
      "Parameter", "Estimate (SE) (m1)", "p (m1)", "Estimate (SE) (m2)",
      "p (m2)", "Estimate (SE) (m3)", "p (m3)"
    )
  )
  expect_identical(
    out$Parameter,
    c(
      "(Intercept)", "Species (versicolor)", "Species (virginica)",
      "Petal Length", "Species (versicolor) * Petal Length",
      "Species (virginica) * Petal Length", "outcome (2)", "outcome (3)",
      "treatment (2)", "treatment (3)", NA, "Observations"
    )
  )
})


data(mtcars)
m1 <- lm(mpg ~ wt, data = mtcars)
m2 <- glm(vs ~ wt + cyl, data = mtcars, family = "binomial")

test_that("compare_parameters, column name with escaping regex characters", {
  out <- utils::capture.output(compare_parameters(m1, m2, column_names = c("linear model (m1)", "logistic reg. (m2)")))
  expect_identical(out[1], "Parameter    |    linear model (m1) |   logistic reg. (m2)")
})


data(mtcars)
m1 <- lm(mpg ~ hp, mtcars)
m2 <- lm(mpg ~ hp, mtcars)
test_that("compare_parameters, proper printing for CI=NULL #820", {
  expect_snapshot(compare_parameters(m1, m2, ci = NULL))
})


skip_on_cran()


test_that("compare_parameters, correct random effects", {
  skip_if_not_installed("glmmTMB")
  skip_if_not(getRversion() >= "4.0.0")

  data("fish")
  m0 <- glm(count ~ child + camper, data = fish, family = poisson())

  m1 <- glmmTMB::glmmTMB(
    count ~ child + camper + (1 | persons) + (1 | ID),
    data = fish,
    family = poisson()
  )

  m2 <- glmmTMB::glmmTMB(
    count ~ child + camper + zg + (1 | ID),
    ziformula = ~ child + (1 | persons),
    data = fish,
    family = glmmTMB::truncated_poisson()
  )

  cp <- compare_parameters(m0, m1, m2, effects = "all", component = "all")
  expect_snapshot(cp)
})
