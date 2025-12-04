# Populate publication summaries
# This script adds all the biological outcome summaries to the CSV

library(dplyr)

# Read the summary data
pub_data <- read.csv("publications_summary_data.csv", stringsAsFactors = FALSE)

# Define all summaries
summaries <- list(
  "Distributed control circuits across a brain-and-cord connectome" =
    "The first complete adult fly connectome uniting brain and ventral nerve cord reveals that motor control is organized through local sensory-motor feedback loops within body segments, which are coordinated by long-range ascending and descending neurons arranged into behavior-centric modules. This distributed, hierarchical architecture shows that brain regions supporting learning and navigation supervise lower-level circuits, enabling flies to coordinate complex behaviors like flight and walking while maintaining rapid sensory responsiveness.",

  "Neural circuit mechanisms for steering control in walking Drosophila" =
    "Two specialized descending neuron types control steering at different timescales during walking: DNa01 mediates sustained low-gain steering while DNa02 produces rapid high-gain turns by integrating head direction signals with multimodal sensory inputs. These neurons operate through a 'see-saw' organizational principle where excitation of one brain hemisphere's descending neuron is paired with inhibition of the opposite side, enabling precise bilateral coordination of turning movements.",

  "Comparative connectomics of Drosophila descending and ascending neurons" =
    "Complete reconstruction of 1,315-1,347 descending neurons and 1,733-1,865 ascending neurons traversing the neck connective reveals that descending neurons receive predominantly preprocessed sensory information from brain interneurons rather than direct sensory input, while ascending neurons provide crucial motor state feedback to the brain. Sexual dimorphism is concentrated in reproductive circuits, with 1% of descending and 4% of ascending neurons showing sex-specific connectivity patterns that support courtship song production in males and reproductive behaviors in females.",

  "Sexual dimorphism in the complete connectome of the Drosophila male central nervous system" =
    "The first complete male Drosophila central nervous system connectome (166,000+ neurons) reveals 262 sex-specific and 114 sexually dimorphic cell types comprising 4.8% of the central brain, concentrated in higher-order brain centers while sensory and motor periphery remain largely isomorphic. Although dimorphic neurons represent a small fraction of total neurons, sexual dimorphism propagates through the nervous system via dimorphic connectivity patterns, providing the neural substrate for behavioral differences between males and females in mating and aggression.",

  "Quantitative Attributions with Counterfactuals" =
    "This computational method enables quantitative attribution analysis in deep neural network classifiers by generating counterfactual images and identifying class-relevant visual differences; when applied to Drosophila electron microscopy data, it revealed previously unknown visual features distinguishing synapses with different neurotransmitters. The approach provides a generalizable framework for discovering subtle morphological differences in biological imaging data that correlate with functional classifications.",

  "A Drosophila computational brain model reveals sensorimotor processing" =
    "The computational model revealed that sugar and water gustatory pathways form a partially shared appetitive feeding initiation pathway, accurately predicting neurons required for taste-evoked feeding behaviors and demonstrating how different taste modalities interact at the circuit level. Computational activation of mechanosensory neurons accurately predicted the neural composition and response properties of the antennal grooming circuit, providing circuit-level insights into how sensory inputs are transformed into specific motor behaviors.",

  "Network statistics of the whole-brain connectome of Drosophila" =
    "The complete fly brain connectome displays rich-club organization, with 30% of neurons being highly connected hub neurons that may serve as integrators or broadcasters of neural signals across the brain. Analysis of network motifs and their relationship to neurotransmitter composition revealed fundamental organizational principles of how information flows through the brain, with specific subsets of rich-club neurons positioned to coordinate activity across different brain regions.",

  "Whole-brain annotation and multi-connectome cell typing of Drosophila" =
    "The systematic annotation identified 8,453 cell types across the whole brain, including 4,581 newly discovered types primarily from regions outside the previously mapped hemibrain, establishing a comprehensive neuronal taxonomy for Drosophila. Comparison of the FlyWire and hemibrain connectomes validated a quantitative definition of cell type based on connectivity patterns, demonstrating that neurons of the same type are more similar across different individual brains than to other neurons within the same brain, revealing the remarkable stereotypy of neural circuit organization.",

  "Neuronal wiring diagram of an adult brain" =
    "The complete reconstruction of 139,255 neurons and 50 million synapses in the adult Drosophila brain provides the first whole-brain connectome of an adult animal, establishing a foundational resource for understanding brain-wide circuit function and information processing. This comprehensive wiring diagram, integrated with cell type annotations, hemilineage classifications, and neurotransmitter predictions, enables systematic investigation of how neural circuits implement complex behaviors at the whole-brain scale.",

  "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster" =
    "Machine learning models achieved 87% accuracy in predicting neurotransmitter identity (acetylcholine, glutamate, GABA, serotonin, dopamine, octopamine) directly from synaptic ultrastructure in electron micrographs, revealing that subtle but consistent morphological differences exist between different transmitter types. The analysis demonstrated that neurons developing from the same lineage predominantly express only one fast-acting transmitter, revealing a fundamental developmental constraint linking neuronal birth, circuit assembly, and chemical signaling properties.",

  "Analysis and optimization of equitable US cancer clinical trial center access by travel time" =
    "The 78 major US cancer trial centers serving 94% of trials are disproportionately located near affluent, predominantly White populations, with catchment areas showing $18,900 higher median incomes and only 1 of 78 centers primarily serving Black populations. The study identifies that most urban areas contain existing hospitals within commutable distance to diverse, socioeconomically disadvantaged populations that could serve as satellite trial sites to reduce geographic barriers to cancer trial participation.",

  "Combinatorial encoding of odors in the mosquito antennal lobe" =
    "Using in vivo electrophysiology with morphological reconstructions, this study revealed that mosquitoes use a combinatorial neural code where individual projection neurons respond to multiple odors and each odor activates unique patterns across 40-50 neurons in the antennal lobe. Odor pairs that produced similar population-level neural activity patterns also elicited similar behavioral responses (attraction or aversion), demonstrating that this combinatorial code enables mosquitoes to efficiently process the hundreds of chemical components in human odor and make host-seeking decisions within 500-750 milliseconds.",

  "Discriminative attribution from paired images" =
    "This computer vision method combined feature attribution with counterfactual explanations to identify previously unknown morphological differences between neurotransmitter types in Drosophila synapses from electron microscopy images. The method revealed that acetylcholine synapses have significantly brighter synaptic clefts than GABA and glutamate (p ≤ 0.0001), glutamate has larger vesicles than GABA (p ≤ 0.001), and glutamate has darker T-bars than acetylcholine, providing quantitative ultrastructural markers that distinguish classical neurotransmitters.",

  "Systems neuroscience: Auditory processing at synaptic resolution" =
    "This dispatch commentary discusses a breakthrough study that achieved the first comprehensive connectomic mapping of Drosophila courtship song perception circuits at synaptic resolution, linking complete neural circuit architecture to physiological response profiles in deeper auditory system layers that had not been fully characterized in any model organism. The work demonstrates how synaptic-level circuit analysis reveals the structural organization underlying neural computations involved in recognizing biologically relevant acoustic signals during courtship behavior.",

  "Information flow, cell types and stereotypy in a full olfactory connectome" =
    "This first complete inventory of olfactory projection neurons in an adult brain revealed that projection neurons are approximately twice as numerous as previously estimated (347 total) and form unexpected axo-axonic hierarchical networks in the lateral horn organized by odor type, suggesting odor channels directly modulate each other. The study discovered that the lateral horn receives extensive feedback from memory centers for integrative processing while the mushroom body receives cleaner sensory input, and identified novel centrifugal neurons that allow learned experience to modulate the gain of innate olfactory responses.",

  "The connectome of the adult Drosophila mushroom body provides insights into function" =
    "Complete reconstruction of all mushroom body Kenyon cells and their synaptic connections reveals that a single dopaminergic neuron can reinforce synapses from hundreds to thousands of Kenyon cells onto specific mushroom body output neurons, providing a circuit mechanism for parallel associative learning across separate olfactory memories. The connectome demonstrates that mushroom body output neurons integrate inputs from distinct Kenyon cell populations with different sparse coding properties, enabling the fly brain to form and retrieve specific learned associations while maintaining discrimination between similar odors.",

  "BAcTrace, a tool for retrograde tracing of neuronal circuits in Drosophila" =
    "This study developed a botulinum toxin-based retrograde tracing system that successfully maps presynaptic partners in Drosophila neural circuits, validating its accuracy by identifying 12 of 16 known connections in divergent lateral horn circuits when compared to electron microscopy data. The tool enables combined anatomical and electrophysiological analysis of connected neurons, detecting functional connections ranging from approximately 10 to over 200 synapses and revealing connectivity strength thresholds relevant to neural computation.",

  "A connectome and analysis of the adult Drosophila central brain" =
    "This landmark study reconstructed approximately 25,000 neurons with 20 million chemical synapses in the hemibrain, revealing fundamental organizational principles including that maximizing packing density appears to be a major evolutionary constraint on brain architecture. The comprehensive connectome enabled discovery of previously unknown cell types and revealed circuit-level insights into associative learning in the mushroom body, navigation and sleep in the central complex, and circadian rhythm regulation.",

  "Connectomics analysis reveals first-, second-, and third-order thermosensory and hygrosensory neurons in the adult Drosophila brain" =
    "This study identified two novel antennal lobe glomeruli and reconstructed 89 projection neurons (38 morphological types, 23 previously unknown) that relay temperature and humidity information to the mushroom body, lateral horn, and the lateral accessory calyx, which serves as a multimodal integration hub linking thermosensation with memory and circadian circuits. Remarkably, the research revealed that dry-responsive neurons connect to descending motor neurons in just two synapses, enabling rapid behavioral responses to desiccation threat.",

  "Input connectivity reveals additional heterogeneity of dopaminergic reinforcement in Drosophila" =
    "This connectomic analysis revealed that the 20 dopaminergic neurons in the mushroom body gamma-5 compartment segregate into 5 anatomical subtypes with distinct input connectivity patterns, demonstrating that different subtypes serve specialized functions in memory formation and reinforcement learning. Behavioral experiments proved functional separation, showing that memory extinction and sugar-reward learning utilize different PAM-gamma-5 dopaminergic neuron subtypes, revealing how compact fly brains encode diverse reward types through anatomical compartmentalization.",

  "Complete connectomic reconstruction of olfactory projection neurons in the fly brain" =
    "This first complete inventory of olfactory projection neurons in an adult brain revealed that projection neurons are approximately twice as numerous as previously estimated (347 total) and form unexpected axo-axonic hierarchical networks in the lateral horn organized by odor type, suggesting odor channels directly modulate each other. The study discovered that the lateral horn receives extensive feedback from memory centers for integrative processing while the mushroom body receives cleaner sensory input, and identified novel centrifugal neurons that allow learned experience to modulate the gain of innate olfactory responses.",

  "The natverse, a versatile toolbox for combining and analysing neuroanatomical data" =
    "This study developed an open-source R toolkit that enables quantitative comparison of neuronal morphology and connectivity across different Drosophila brain template spaces and imaging modalities, facilitating cell-type classification and integration of light microscopy and electron microscopy connectomic datasets. The natverse allows researchers to systematically analyze neuronal branching patterns, cluster neurons by anatomical similarity, and bridge previously incompatible neuroanatomical datasets through unified spatial transformations.",

  "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics" =
    "This review establishes that neuronal cell type definition requires integration of multiple co-varying properties including lineage, gene expression, morphology, connectivity, and behavioral significance, rather than relying on any single characteristic. Initial comparative studies demonstrate high consistency between morphological and transcriptomic classifications of neuronal types, with matched single-cell data providing an effective reference framework for integrating connectomics and functional information across the Drosophila nervous system.",

  "Functional and anatomical specificity in a higher olfactory centre" =
    "This study discovered that the Drosophila lateral horn contains approximately 1,400 neurons across more than 165 cell types, with individual neurons showing stereotyped odor responses across animals and responding to three times more odors than single projection neurons. Lateral horn neurons function as superior odor categorizers compared to their projection neuron inputs through stereotyped pooling of related inputs, enabling extraction of behaviorally meaningful odor categories for innate behavioral responses.",

  "Neurogenetic dissection of the Drosophila lateral horn reveals major outputs, diverse behavioural functions, and interactions with the mushroom body" =
    "This study created genetic access to 82 lateral horn cell types and identified the superior lateral protocerebrum as the major output zone, with optogenetic activation revealing specific cell types that drive attraction, aversion, or distinct motor behaviors. The research discovered that approximately 30% of lateral horn projections converge with mushroom body outputs, revealing a circuit motif where lateral horn axons integrate multiple memory-related inputs alongside multisensory information from visual, mechanosensory, gustatory, and thermosensory systems.",

  "Automated reconstruction of a serial-section EM Drosophila brain with flood-filling networks and local realignment" =
    "This study developed flood-filling networks combined with local realignment procedures to computationally segment a forty-teravoxel serial-section electron microscopy dataset of the Drosophila hemibrain, containing approximately 25,000 neurons and 20 million chemical synapses. The automated reconstruction revealed novel connectivity motifs including axo-axonic connectivity between projection neurons, feedback and lateral inhibition mechanisms, and convergence of olfactory, non-olfactory, and memory-related inputs onto third-order olfactory neurons, while achieving circuit analysis workflows an order of magnitude faster than manual tracing.",

  "Communication from learned to innate olfactory processing centers is required for memory retrieval in Drosophila" =
    "This study identified two lateral horn neuron types (PD2a1 and PD2b1) that receive convergent input from both mushroom body output neurons conveying learned aversive memories and projection neurons carrying innate olfactory signals, with silencing these neurons impairing memory retrieval across multiple timescales. The research revealed that memory retrieval occurs through depression of mushroom body output neuron responses to conditioned stimuli, which reduces excitatory drive through cholinergic lateral horn neurons to downstream approach circuits, thereby enabling learned avoidance behavior.",

  "Neural circuit basis of aversive odour processing in Drosophila from sensory input to descending output" =
    "This study used connectomics to map the complete synaptic circuit processing aversive odors like geosmin from sensory receptors through descending output neurons, revealing that geosmin-responsive second-order olfactory neurons diverge to connect with approximately 75 distinct cell types. The circuit architecture transitions from labeled-line organization at the sensory periphery to a distributed representation where olfactory information maps onto diverse higher-order populations with distinct behavioral functions, including novel axo-axonic convergence mechanisms for integrating multiple danger signals such as parasitoid wasp pheromones."
)

# Populate summaries
for (title in names(summaries)) {
  pub_data$summary[pub_data$title == title] <- summaries[[title]]
}

# Save updated data
write.csv(pub_data, "publications_summary_data.csv", row.names = FALSE)

# Print summary
cat("\nSummaries populated!\n")
cat("Total publications:", nrow(pub_data), "\n")
cat("Publications with summaries:", sum(!is.na(pub_data$summary) & pub_data$summary != ""), "\n")
cat("Missing summaries:", sum(is.na(pub_data$summary) | pub_data$summary == ""), "\n")
