use std::fs::File;
use std::io::Write;

use linfa::prelude::*;
use linfa_trees::DecisionTree;
use linfa_trees::SplitQuality;
use ndarray::array;
use ndarray::prelude::*;

fn main() {
    let original_data: Array2<f32> = array!(
        // WORK, went out, played guitar, drove a car, happiness 1 - 10
        [1., 1., 0., 1., 8.],
        [1., 0., 1., 1., 7.],
        [1., 0., 0., 0., 2.],
        [1., 0., 0., 0., 8.],
        [1., 1., 1., 1., 8.],
        [1., 0., 1., 1., 6.],
        [1., 0., 1., 1., 8.],
        [1., 1., 0., 1., 3.],
        [1., 1., 0., 1., 2.],
        [1., 1., 0., 0., 1.],
        [1., 0., 1., 0., 8.],
    );

    let feature_names = vec!["Worked", "Went out", "Played guitar", "Drove a car"];

    // Axis 0 is rows Axis 1 is columns
    let num_features = original_data.len_of(Axis(1)) - 1;
    // separate features array, all the rows all the cols except the last one
    let features = original_data.slice(s![.., 0..num_features]).to_owned();
    let labels = original_data.column(num_features).to_owned();

    // Linfa dataset
    let linfa_dataset = Dataset::new(features, labels)
        // Map set of values to string, convert all values to i32
        .map_targets(|x| match x.to_owned() as i32 {
            // Declare happiness states ranges
            i32::MIN..=4 => "Sad",
            5..=7 => "Ok",
            8..=i32::MAX => "Happy",
        })
        .with_feature_names(feature_names);

    // Fit dataset onto decision tree model
    let model = DecisionTree::params()
        .split_quality(SplitQuality::Gini)
        .fit(&linfa_dataset)
        // not in production so whole program can fail
        .unwrap();

      // Visualize into LaTeX
      File::create("dt.tex")
      .unwrap()
      .write_all(model.export_to_tikz().with_legend().to_string().as_bytes())
      .unwrap();
}
