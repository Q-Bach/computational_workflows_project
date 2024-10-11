import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Function to process each TSV file and return the top 10 genes with reads
def process_tsv(file):
    df = pd.read_csv(file, sep='\t', skiprows=1)
    # Sort the DataFrame by the number of reads in the last column
    df_sorted = df.sort_values(by=df.columns[-1], ascending=False)
    # Select top 10 genes
    return df_sorted.head(10)

# Step 1: Process both TSV files
file1 = 'SRR23195511_oxy_sham.featureCounts.txt'
file2 = 'SRR23195516_oxy_sni.featureCounts.txt'

top_10_file1 = process_tsv(file1)
top_10_file2 = process_tsv(file2)

# Step 2: Merge both datasets based on the gene_id (first column)
merged_df = pd.merge(top_10_file1[[top_10_file1.columns[0], top_10_file1.columns[-1]]],
                     top_10_file2[[top_10_file2.columns[0], top_10_file2.columns[-1]]],
                     on=top_10_file1.columns[0],
                     how='inner', suffixes=('_file1', '_file2'))

# Step 3: Create a grouped bar plot
genes = merged_df[merged_df.columns[0]]  # gene_id column
reads_file1 = merged_df[merged_df.columns[1]]  # reads from file1
reads_file2 = merged_df[merged_df.columns[2]]  # reads from file2

# Define the position of bars on the x-axis
bar_width = 0.35
index = np.arange(len(genes))

plt.figure(figsize=(10,6))

# Plot bars for file1 and file2
plt.bar(index, reads_file1, bar_width, label='SRR23195511', color='skyblue')
plt.bar(index + bar_width, reads_file2, bar_width, label='SRR23195516', color='salmon')

# Step 4: Add labels, title, and legend
plt.xlabel('Gene ID')
plt.ylabel('Number of Reads')
plt.title('Top 10 Genes by Number of Reads')
plt.xticks(index + bar_width / 2, genes, rotation=45, ha="right")
plt.legend()

# Adjust layout to avoid overlapping
plt.tight_layout()

# Show plot
plt.show()
