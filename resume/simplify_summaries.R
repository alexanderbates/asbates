# Simplify publication summaries to be more concise
library(dplyr)

pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Simplified summaries (1-2 sentences, focusing on key biological findings)
simplified <- list(
  "Distributed control circuits across a brain-and-cord connectome" =
    "The first complete connectome linking brain and ventral nerve cord reveals distributed motor control through local sensory-motor loops coordinated by behavior-specific descending neurons. Brain regions supervising learning and navigation coordinate lower-level circuits for complex behaviors like flight and walking.",

  "Neural circuit mechanisms for steering control in walking Drosophila" =
    "Two descending neuron types control steering at different timescales: DNa01 for sustained turns and DNa02 for rapid turns via head direction integration. These neurons use bilateral coordination where one hemisphere's excitation pairs with opposite-side inhibition.",

  "Comparative connectomics of Drosophila descending and ascending neurons" =
    "Complete reconstruction of 1,300+ descending and 1,700+ ascending neurons shows descending neurons receive preprocessed sensory information while ascending neurons provide motor feedback. Sexual dimorphism concentrates in reproductive circuits with 1-4% of neurons showing sex-specific connectivity.",

  "Sexual dimorphism in the complete connectome of the Drosophila male central nervous system" =
    "The male CNS connectome reveals 262 sex-specific and 114 dimorphic cell types (4.8% of brain) concentrated in higher-order centers. Dimorphic connectivity patterns provide neural substrates for behavioral differences in mating and aggression.",

  "Quantitative Attributions with Counterfactuals" =
    "This computational method identifies visual features distinguishing neurotransmitter types from EM images, revealing morphological differences between synapses. The approach provides a framework for discovering subtle biological differences in imaging data.",

  "A Drosophila computational brain model reveals sensorimotor processing" =
    "Computational modeling revealed how sugar and water pathways form shared appetitive feeding circuits and predicted neurons required for taste-evoked behaviors. The model provides circuit-level insights into sensory-motor transformations.",

  "Network statistics of the whole-brain connectome of Drosophila" =
    "The fly brain shows rich-club organization with 30% of neurons being highly connected hubs. Network analysis revealed organizational principles of information flow across brain regions.",

  "Whole-brain annotation and multi-connectome cell typing of Drosophila" =
    "Systematic annotation identified 8,453 cell types including 4,581 newly discovered types. Comparison across connectomes validated that cell types are more similar across brains than within brains, revealing circuit stereotypy.",

  "Neuronal wiring diagram of an adult brain" =
    "Complete reconstruction of 139,255 neurons and 50 million synapses provides the first whole-brain connectome of an adult animal. This resource enables systematic investigation of brain-wide circuit function.",

  "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster" =
    "Machine learning achieved 87% accuracy predicting neurotransmitter identity from synaptic ultrastructure. Analysis revealed neurons from the same lineage predominantly express one fast-acting transmitter.",

  "Analysis and optimization of equitable US cancer clinical trial center access by travel time" =
    "Major US cancer trial centers are disproportionately located near affluent White populations. Most urban areas contain hospitals within commutable distance to disadvantaged populations for satellite sites.",

  "Combinatorial encoding of odors in the mosquito antennal lobe" =
    "Mosquitoes use combinatorial coding where individual neurons respond to multiple odors and each odor activates unique patterns. Similar neural patterns produce similar behavioral responses within 500-750ms.",

  "Discriminative attribution from paired images" =
    "This method identified morphological differences between neurotransmitter types including brighter synaptic clefts for acetylcholine and larger vesicles for glutamate. It provides quantitative ultrastructural markers distinguishing transmitters.",

  "Systems neuroscience: Auditory processing at synaptic resolution" =
    "This commentary discusses the first synaptic-resolution mapping of Drosophila courtship song circuits. The work reveals structural organization underlying acoustic signal recognition.",

  "Information flow, cell types and stereotypy in a full olfactory connectome" =
    "First complete olfactory projection neuron inventory revealed 347 neurons forming axo-axonic networks organized by odor type. The lateral horn receives memory feedback while mushroom body receives cleaner sensory input.",

  "The connectome of the adult Drosophila mushroom body provides insights into function" =
    "Complete mushroom body reconstruction reveals single dopamine neurons can reinforce synapses from thousands of Kenyon cells. This provides a circuit mechanism for parallel associative learning across memories.",

  "BAcTrace, a tool for retrograde tracing of neuronal circuits in Drosophila" =
    "Botulinum toxin-based retrograde tracing maps presynaptic partners with 75% accuracy versus EM. The tool enables combined anatomical and electrophysiological analysis.",

  "A connectome and analysis of the adult Drosophila central brain" =
    "The hemibrain reconstruction of 25,000 neurons and 20 million synapses revealed that packing density is a major evolutionary constraint. It enabled discovery of circuit mechanisms for learning, navigation, and sleep.",

  "Connectomics analysis reveals first-, second-, and third-order thermosensory and hygrosensory neurons in the adult Drosophila brain" =
    "Reconstruction of 89 projection neurons (23 previously unknown) revealed temperature and humidity information reaches memory and circadian circuits. Dry-responsive neurons connect to motor neurons in two synapses.",

  "Input connectivity reveals additional heterogeneity of dopaminergic reinforcement in Drosophila" =
    "The 20 dopamine neurons in mushroom body gamma-5 segregate into 5 subtypes with distinct inputs. Different subtypes serve specialized functions in memory extinction versus reward learning.",

  "Complete connectomic reconstruction of olfactory projection neurons in the fly brain" =
    "Complete inventory revealed projection neurons are twice as numerous as estimated (347 total) and form axo-axonic networks. Centrifugal neurons allow learned experience to modulate innate responses.",

  "The natverse, a versatile toolbox for combining and analysing neuroanatomical data" =
    "This R toolkit enables quantitative comparison of neuronal morphology across different brain spaces and imaging modalities. It bridges previously incompatible datasets through unified spatial transformations.",

  "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics" =
    "This review establishes that cell type definition requires integrating lineage, gene expression, morphology, connectivity, and function. Morphological and transcriptomic classifications show high consistency.",

  "Functional and anatomical specificity in a higher olfactory centre" =
    "The lateral horn contains 1,400 neurons across 165+ types with stereotyped odor responses. Lateral horn neurons categorize odors better than their inputs through stereotyped pooling.",

  "Neurogenetic dissection of the Drosophila lateral horn reveals major outputs, diverse behavioural functions, and interactions with the mushroom body" =
    "Genetic access to 82 lateral horn types revealed specific cells driving attraction, aversion, or motor behaviors. 30% of projections converge with mushroom body outputs for memory integration.",

  "Automated reconstruction of a serial-section EM Drosophila brain with flood-filling networks and local realignment" =
    "Flood-filling networks computationally segmented the hemibrain 10× faster than manual tracing. Automated reconstruction revealed axo-axonic connectivity and feedback mechanisms.",

  "Communication from learned to innate olfactory processing centers is required for memory retrieval in Drosophila" =
    "Two lateral horn neurons integrate mushroom body memory signals with olfactory input. Memory retrieval occurs through depression of mushroom body output reducing excitatory drive to approach circuits.",

  "Neural circuit basis of aversive odour processing in Drosophila from sensory input to descending output" =
    "Complete circuit from geosmin receptors to descending neurons shows second-order neurons connect to 75 cell types. Circuit transitions from labeled-line to distributed representation with axo-axonic danger signal integration.",

  "Connectome Influence Calculator" =
    "This software computes neural influence scores using dynamical models of signal propagation. It identifies which neurons functionally control information flow beyond direct connectivity."
)

# Update summaries
for (title in names(simplified)) {
  pub_data$summary[pub_data$title == title] <- simplified[[title]]
}

write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)
cat("\nSummaries simplified!\n")
