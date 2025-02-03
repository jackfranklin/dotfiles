local M = {}

M.setup = function()
  require("parrot").setup({
    providers = {
      gemini = {
        api_key = os.getenv("GEMINI_API_KEY"),
      },
    },
    hooks = {
      Outline = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the entire code in this file, carefully examine it, and then
        report an outline of the core parts of the code.
        Keep your explanation short and to the point and format it using markdown:

        ```{{filetype}}
        {{filecontent}}
        ```
        ]]
        local model_obj = prt.get_model("command")
        prt.logger.info("Outlining file with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      SpellCheck = function(prt, params)
        local template = [[
        Your task is to look through the code provided in the file and list any
        potential spelling mistakes. Quote each part that you think is
        incorrect. Suggest the correct
        spelling. Correct any spelling mistakes, punctuation
        errors, verb tense issues, word choice problems, and other
        grammatical mistakes. Return your answer as a formatted markdown list.
        The start of each item should follow the format "Line X", replacing "X"
        with the actual line number, and make the "Line X" part bold. Return
        the lines sorted in ascending order.

        Here is the input to check:
        ```{{filetype}}
        {{filecontent}}
        ```
        ]]
        local model_obj = prt.get_model("command")
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      Debug = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{selection}}
        ```
        ]]
        local model_obj = prt.get_model("command")
        prt.logger.info("Debugging selection with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      DebugFile = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{filecontent}}
        ```
        ]]
        local model_obj = prt.get_model("command")
        prt.logger.info("Debugging selection with model: " .. model_obj.name)
        prt.Prompt(params, prt.ui.Target.vnew, model_obj, nil, template)
      end,
      CommitMsg = function(prt, params)
        local futils = require("parrot.file_utils")
        if futils.find_git_root() == "" then
          prt.logger.warning("Not in a git repository")
          return
        else
          local template = [[
          I want you to act as a commit message generator. I will provide you
          with information about the task and the prefix for the task code, and
          I would like you to generate an appropriate commit message.

          IMPORTANT: do not use the conventional commit format or any other format that prefixes the commit message.
          Do not write any explanations or other words, just reply with the commit message.
          Start with a short headline as summary and then list the individual changes in more detail.

          Here are the changes that should be considered by this message:
          ]] .. vim.fn.system("git diff --no-color --no-ext-diff --staged")
          local model_obj = prt.get_model("command")
          prt.Prompt(params, prt.ui.Target.rewrite, model_obj, nil, template)
        end
      end,
    },
  })
  vim.keymap.set("n", "<leader>lcn", ":PrtChatNew<CR>", {
    desc = "[c]hat [n]ew: Open a new chat with Parrot",
  })
  vim.keymap.set("n", "<leader>lct", ":PrtChatToggle<CR>", {
    desc = "[c]hat [t]oggle with Parrot",
  })
  vim.keymap.set("n", "<leader>lgm", ":PrtCommitMsg<CR>", {
    desc = "[g]it [m]essage: Generate a commit message with Parrot",
  })
end

return M
