**Stimulus-Driven Internal Attention - Eye-Tracking Analysis**

This repository contains MATLAB scripts for analyzing gaze position, microsaccades, and saccade bias to study how stimulus-driven internal attention is modulated by task relevance in working memory.

The analyses were developed as part of a Research Master’s thesis in Cognitive Neuropsychology at Vrije Universiteit Amsterdam.


**Overview**

The project investigates whether non-predictive external cues can bias attention toward internal memory representations, and whether this effect depends on whether the cued feature is task-relevant (color vs location).

Behavioral measures and eye-tracking data are combined to track covert attentional shifts over time.


**Methods**

Modified retro-cue working memory paradigm

Eye-tracking (EyeLink 1000 Plus)

Gaze position, microsaccade direction, saccade rate and size

Time-resolved analysis and grand averaging

Cluster-based permutation statistics


**Main Analyses**

Gaze position and towardness computation

Microsaccade classification (toward vs away)

Saccade bias and saccade size analysis

Grand-average plots and condition comparisons

Cluster-based permutation testing (10,000 permutations)


**Requirements**

MATLAB

FieldTrip toolbox

Custom helper functions (frevede_errorbarplot, frevede_ftclusterstat1D)


**Data**

Raw data are not included due to ethics and privacy constraints. Scripts assume participant-wise .mat files with consistent naming.


**Author**

Fathima Shamsuddin
Research Master Cognitive Neuropsychology
Vrije Universiteit Amsterdam

Supervisor: Dr. Freek van Ede
Co-supervisor: Anna van Harmelen
