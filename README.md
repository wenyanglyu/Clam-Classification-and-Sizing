# Clam Classification and Sizing System

## Overview
This repository contains the implementation of an automated system for classifying and sizing marine clams using computer vision and machine learning techniques. The system combines traditional image processing with advanced machine learning methods to identify different clam species and accurately measure their sizes.

![demo2](https://github.com/user-attachments/assets/87fa11d0-cbb2-4d6b-89f6-288e6cd8123d)

## Research Background
The system was developed to address the challenge of efficiently classifying and sizing marine clams, which is a legislative requirement for shellfish processing in New Zealand. Traditional manual methods are labor-intensive and prone to human error. This automated approach significantly improves both accuracy and efficiency.

## Features
- **Automated Classification**: Identifies clam species using a combination of image features and machine learning
- **Accurate Sizing**: Measures clam dimensions with high precision using camera calibration techniques
- **Robust Performance**: Works effectively under varying lighting conditions
- **Overlapping Clam Detection**: Uses advanced contour reconstruction to handle overlapping clams

## Clam Species
The system is designed to classify four types of clams:
- Cockles (Austrovenus stutchburyi)
- Dosinia (Dosinia anus)
- Tuatua (Paphies subtriangulata)
- Mussels (Perna canaliculus)

## Technical Approach

### Classification Methods
The system implements three main classification approaches:
1. **Traditional Feature Extraction**: Morphological features, texture features (GLCM), and frequency features (DCT)
2. **CNN-Based Feature Extraction**: Using pre-trained networks (AlexNet, ResNet-50, NASNet-Large)
3. **Transfer Learning**: Adapting pre-trained networks to the specific task of clam classification

The best performance was achieved using **ResNet-50 with a polynomial SVM classifier**, which delivered consistent accuracy across different lighting conditions.

### Sizing Method
The sizing process involves:
1. **Camera Calibration**: Using Zhang's method with a checkerboard pattern
2. **Scaling Factor**: Applied to correct measurement distortions
3. **Feret Diameter Calculation**: Identifying the maximum and minimum distances across a clam's boundary

### Handling Overlapping Clams
The system uses a GAN-based approach to reconstruct obscured portions of clam contours, ensuring accurate measurements even when clams overlap.

## Performance
- **Classification Accuracy**: Up to 97.33% using ResNet-50 with SVM across varying lighting conditions
- **Sizing Accuracy**: Root Mean Square Error (RMSE) reduced from 3.35mm to 1.39mm after applying the scaling factor

## Applications
- Commercial fishing operations
- Ecological surveys
- Marine resource management
- Automated quality control in shellfish processing
