function likelihood = normpdf(x, mu, sigma)

likelihood = exp(-((x-mu)^2)/2/sigma/sigma)/sigma/sqrt(2*pi);