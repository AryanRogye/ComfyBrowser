        TopBar----------SearchSuggestionProvider
          |
          V
SearchSuggestionsList-----SearchSuggestionCollectionCoordinator-|
          |                                                     |
          V                                                     |
SearchSuggestionScrollView                                      |
          |                                                     |
          V                                                     |
SearchSuggestionCollectionView<---------------------------------|
          |
          V
 SearchSuggestionItem------SearchSuggestion                     |
          |                                                     |
          V                                                     |
SearchSuggestionItemView (Tap + Hover)                          |
          |                                                     |
          V                                                     |
 SearchSuggestionRow (Content)<---------------------------------|


The Views folder belongs in `Features/Search` because this will be used by the search in the topBar and in a launcher for command t
