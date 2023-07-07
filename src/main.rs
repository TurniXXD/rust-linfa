// .ot
// config
// vocab
// merges

fn main() {
    // For production ready code use local resources instead

    // Load pre-trained model
    let model_resource = Box::new(RemoteResource::from_pretrained(
        GptNeoModelResources::GPT_NEO_2_TB,
    ));

    // Load config file
    let config_resource = Box::new(RemoteResource::from_pretrained(
        GptNeoConfigResources::GPT_NEO_2_TB,
    ));

    // Load vocab file
    let vocab_resource = Box::new(RemoteResource::from_pretrained(
        GptNeoVocabResources::GPT_NEO_2_TB,
    ));

    // Load merges file
    let merges_resource = Box::new(RemoteResource::from_pretrained(
        GptNeoMergesResources::GPT_NEO_2_TB,
    ));

    let generate_config = TextGenerationConfig {
      model_type: ModelType::GPTNeo,
      model_resource,
      config_resource,
      vocab_resource,
      merges_resource,
      // Different potential continuations of text
      num_beames: 5,
      // Only generate n-gram of repetetive output in generated text 
      no_repeat_ngram_size: 2,
      // Maximum length of text
      max_length:100
      ..Default::default()
    };

    let model = TextGenerationModel::new(generate_config).unwrap();

    loop {
      let mut line = String::new();
      // Read user input
      std::io::stdin().read_line(&mut line).unwrap();
      // Split user input with "/"
      let split = line.split('/').collect::<Vec<&str>>();
      let slc = split.as_slice();
      // Perform the text generation, take element 1 of the slice and everything after that as an input, and element 0 as text generation prefix
      let output = model.generate(&slc[1..], Some(slc[0]));

      for sentence in output {
        println!("{}", sentence);
      }
    }
}
