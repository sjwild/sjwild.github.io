
data {
  int<lower=1> T;
  array[T] int<lower=0> y;
  array[T] real x;
  
  // priors
  real prior_alpha_sigma;
  real prior_beta_sigma;
  real prior_sigma;
}

transformed data {
  real log_unif;
  log_unif = -log(T);
}

parameters {
  array[2] real alpha;
  array[2] real beta;
  real<lower=0> sigma;
}

transformed parameters {
    vector[T] lp;
    vector[T] mu1;
    vector[T] mu2;
    {
      vector[T + 1] lp_1;
      vector[T + 1] lp_2;
      lp_1[1] = 0;
      lp_2[1] = 0;
      for (t in 1:T) {
        mu1[t] = alpha[1] + beta[1] * x[t];
        mu2[t] = alpha[2] + beta[2] * x[t];

        lp_1[t + 1] = lp_1[t] + normal_lpdf(y[t] | mu1[t], sigma);
        lp_2[t + 1] = lp_2[t] + normal_lpdf(y[t] | mu2[t], sigma);
      }
      lp = rep_vector(log_unif + lp_2[T + 1], T)
           + head(lp_1, T) - head(lp_2, T);
    }
  }

model {
  alpha ~ normal(0, prior_alpha_sigma);
  beta ~ normal(0, prior_beta_sigma);
  sigma ~ exponential(prior_sigma);
  target += log_sum_exp(lp);
}

generated quantities {
  int<lower=1, upper=T> s;
  s = categorical_logit_rng(lp);
}


