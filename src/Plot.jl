using Oxygen
using Oxygen: html
using HTTP



@swagger """
"/plot":
  get:
    summary: Plot a view of the register network
    description: Plots the register network and returns html for it

    responses:
      '200':
        description: Successfully received the plot
"""
@get "/plot" function (req::HTTP.Request)  
  @info "Received request to plot the register network"
  return html(f)
  # return diis
  # pn = png(fig)

  # response = """
  #   <h1 style="margin-left: 1%"> Register Net Plot</h1>
  #   <p style="margin-left: 1%">$reg_net</p>
  #   <img height=450 width=600 style="border:1px solid black; margin-left: 1%" src="data:image/png;base64, $(base64encode(pn.body))" />
  # """

  # return response
end

