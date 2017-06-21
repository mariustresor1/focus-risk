module Types exposing (..)

import Kinto
import Set


type alias Model =
    { email : Maybe String
    , password : Maybe String
    , error : Maybe String
    , currentPage : Pages
    , threatForm : ThreatFormData
    }


type alias ThreatFormData =
    { threat_objectives_at_stake : Set.Set String
    , threat_project_package : String
    , threat_type : String
    , threat_description : String
    , threat_title : String
    , threat_cause : String
    , threat_impact_schedule : String
    , threat_impact_cost : String
    , threat_impact_performance : String
    , threat_probability : String
    , threat_mitigation : String
    }


emptyThreatForm : ThreatFormData
emptyThreatForm =
    { threat_objectives_at_stake = Set.empty
    , threat_project_package = ""
    , threat_type = ""
    , threat_description = ""
    , threat_title = ""
    , threat_cause = ""
    , threat_impact_schedule = ""
    , threat_impact_cost = ""
    , threat_impact_performance = ""
    , threat_probability = ""
    , threat_mitigation = ""
    }


type Pages
    = LoginPage
    | HomePage
    | ThreatForm
    | ConfirmationPage
    | DashboardPage


type Msg
    = NewEmail String
    | NewPassword String
    | Login
    | FetchRecordsResponse (Result Kinto.Error (Kinto.Pager Record))
    | GoToThreatForm
    | ThreatFieldChange ThreatInput String
    | GoToConfirmationPage
    | GoToDashboardPage


type ThreatInput
    = ThreatObjectives
    | ThreatProjectPackage
    | ThreatType
    | ThreatDescription
    | ThreatTitle
    | ThreatCause
    | ThreatImpactSchedule
    | ThreatImpactCost
    | ThreatImpactPerformance
    | ThreatProbability
    | ThreatMitigation


type alias Record =
    { id : String
    , last_modified : Int
    }
