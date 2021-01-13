### Algorithm for checking a number for prime

```Prove_prime(p)```, where *p* is a prime or not.
The function implements the Goldwasser-Killain simplicity test algorithm and returns (with a high probability) 
either certificate of prime number *p* or divisor *p*; returns “fail” with low probability.

```Check_prime(p, Cert = [(A0, B0), L0, p1],... [(Ai, Bi), Li, p{i+1}])```, where *Cert* is the certificate of the prime number *p0*. 
The function implements the algorithm for checking a certificate for prime number and returns either “Accept” (if the certificate is accepted) or “Reject” with an explanation why.
