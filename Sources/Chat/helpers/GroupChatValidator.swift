func createGroupOptionValidator(
  _ option: PushChat.CreateGroupOptions
) throws {
  if option.name.isEmpty {
    fatalError("groupName cannot be null or empty")
  }

  if option.name.count > 50 {
    fatalError("groupName cannot be more than 50 characters")
  }

  if option.description.count > 150 {
    fatalError("groupDescription cannot be more than 150 characters")
  }

  guard option.members.count > 0 else {
    fatalError("members cannot be null")
  }

  for member in option.members {
    if !isValidETHAddress(address: member) {
      fatalError("Invalid member address!")
    }
  }

  // for admin in option.admins {
  //   if !isValidETHAddress(address: admin) {
  //     fatalError("Invalid admin address!")
  //   }
  // }
}

func updateGroupOptionValidator(
  _ option: UpdateGroupOptions
) throws {
  if option.name.isEmpty {
    fatalError("groupName cannot be null or empty")
  }

  if option.name.count > 50 {
    fatalError("groupName cannot be more than 50 characters")
  }

  if option.description.count > 150 {
    fatalError("groupDescription cannot be more than 150 characters")
  }

  guard option.members.count > 0 else {
    fatalError("members cannot be null")
  }

  for member in option.members {
    if !isValidETHAddress(address: member) {
      fatalError("Invalid member address!")
    }
  }

  // for admin in option.admins {
  //   if !isValidETHAddress(address: admin) {
  //     fatalError("Invalid admin address!")
  //   }
  // }
}
