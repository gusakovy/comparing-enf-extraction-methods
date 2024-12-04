# Comparing ENF Extraction Methods

### Authors: Roy Maiberger, Yakov Gusakov, Lital Dabush, Tirza Routtenberg
### Affiliation: Ben Gurion University of the Negev, Be'er-Sheva, Israel


## Description

This repository contains the code for the paper "Empirical Evaluation of ENF Extraction Methods
for Accurate Timestamping in Multimedia Forensics" submitted for the CISS 2025 conference.

## Overview

The extraction of electrical network frequency (ENF) from audio signals has become a vital tool in multimedia forensics,
enabling applications such as timestamps, authentication and geolocation estimation. 
Our goal with this project was to provide a comparative analysis of several prominent ENF extraction methods and their effectiveness for time stamping audio recordings.

This repository provides a tool for:

1. ENF signal extraction using one of the following methods:

	* Short Time Fourier Transform (STFT)
	* Maximum-likelihood (ML) [1]
	* Blackman-Tukey (BT) [2]
	* Estimation by Rotational Invariance Techniques (ESPRIT) [2]
	* Capon [2]

2. Correlation computations between a measurement signal and a reference signal using Cross-Correlation (CC) and 
Normalized-Missalignment (NM) criteria.

3. Time stamping of a measurement signal within a reference signal based on the chosen correlation criteria.

4. Viauslizations of the correlation sequence and the aligned ENF signals.

## Dependencies

MATLAB: Image Processing Toolbox, Signal Processing Toolbox.

## Running Instructions

1. Add your measurement and reference signals to the `Data` folder.

2. Change the file paths in the `main.m` file to match your file names.

3. Edit the `get_params.m` file to match your needs.

4. Execute the `main.m` file.

## Disclosure

This repository contains code taken from external sources. 
Small adaptations were made to fit our code, and unused parts were removed.

The original code for the ML method can be found at https://ieeexplore.ieee.org/abstract/document/6482617 under "supplemental items".

The original code for the BT, ESPRIT, and CAPON methods can be found at https://github.com/geokarant/ENF_extraction.

## References

[1] D. Bykhovsky and A. Cohen, “Electrical network frequency (enf ) maximum-likelihood estimation via a 
multitone harmonic model,” IEEE Transactions on Information Forensics and Security, vol. 8, no. 5, pp. 744–753, 2013.

[2] G. Karantaidis and C. Kotropoulos, “Assessing spectral estimation methods for electric network frequency 
extraction, ” in Proceedings of the 22nd Pan-Hellenic Conference on Informatics, 2018, pp. 202–207.
