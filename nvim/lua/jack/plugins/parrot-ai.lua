local keys = require("jack.llm-keys")
local M = {}

local providers = {}

if keys.has_gemini then
  providers.gemini = {
    api_key = os.getenv(keys.env.gemini),
    -- Taken from the config example here: https://github.com/frankroeder/parrot.nvim
    name = "gemini",
    endpoint = function(self)
      return "https://generativelanguage.googleapis.com/v1beta/models/"
        .. self._model
        .. ":streamGenerateContent?alt=sse"
    end,
    model_endpoint = function(self)
      return { "https://generativelanguage.googleapis.com/v1beta/models?key=" .. self.api_key }
    end,
    params = {
      chat = { temperature = 1.1, topP = 1, topK = 10, maxOutputTokens = 8192 },
      command = { temperature = 0.8, topP = 1, topK = 10, maxOutputTokens = 8192 },
    },
    topic = {
      model = "gemini-1.5-flash",
      params = { maxOutputTokens = 64 },
    },
    headers = function(self)
      return {
        ["Content-Type"] = "application/json",
        ["x-goog-api-key"] = self.api_key,
      }
    end,
    models = {
      "gemini-2.5-flash-preview-05-20",
      "gemini-2.5-pro-preview-05-06",
      "gemini-1.5-pro-latest",
      "gemini-1.5-flash-latest",
      "gemini-2.5-pro-exp-03-25",
      "gemini-2.0-flash-lite",
      "gemini-2.0-flash-thinking-exp",
      "gemma-3-27b-it",
    },
    preprocess_payload = function(payload)
      local contents = {}
      local system_instruction = nil
      for _, message in ipairs(payload.messages) do
        if message.role == "system" then
          system_instruction = { parts = { { text = message.content } } }
        else
          local role = message.role == "assistant" and "model" or "user"
          table.insert(contents, { role = role, parts = { { text = message.content:gsub("^%s*(.-)%s*$", "%1") } } })
        end
      end
      local gemini_payload = {
        contents = contents,
        generationConfig = {
          temperature = payload.temperature,
          topP = payload.topP or payload.top_p,
          maxOutputTokens = payload.max_tokens or payload.maxOutputTokens,
        },
      }
      if system_instruction then
        gemini_payload.systemInstruction = system_instruction
      end
      return gemini_payload
    end,
    process_stdout = function(response)
      if not response or response == "" then
        return nil
      end
      local success, decoded = pcall(vim.json.decode, response)
      if
        success
        and decoded.candidates
        and decoded.candidates[1]
        and decoded.candidates[1].content
        and decoded.candidates[1].content.parts
        and decoded.candidates[1].content.parts[1]
      then
        return decoded.candidates[1].content.parts[1].text
      end
      return nil
    end,
  }
elseif keys.has_github then
  providers.github = {
    api_key = os.getenv(keys.env.github),
  }
end

M.setup = function()
  require("parrot").setup({
    providers = providers,
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
